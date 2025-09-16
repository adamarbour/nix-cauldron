{ lib, pkgs, config, sources, ... }:
let
  inherit (lib)
    mkOption mkEnableOption types mkIf mapAttrsToList attrNames filterAttrs
    optionalAttrs getAttrFromPath concatStringsSep optionalString;

  secretsRepo = sources.secrets;
  cfg = config.cauldron.host.network.wireguard;
  thisHost = config.networking.hostName;

  # Helpers
  isV6 = ip: lib.hasInfix ":" ip;
  bracketIfV6 = host: if isV6 host then "[${host}]" else host;

  # Turn "A.B.C.D/xx" -> "A.B.C.D/32" and IPv6 -> /128.
  # If no CIDR is present, assume host (/32 or /128) based on address family.
  hostCIDR = addr: let
    parts = lib.splitString "/" addr;
    ip    = builtins.elemAt parts 0;
    mask  = if (isV6 ip) then "128" else "32";
  in "${ip}/${mask}";

  mkSecretName = name: "wg-${name}-key";
  mkIfaceName  = name: "wg-${name}";

  mkEndpoint = host: port:
    if host == null || port == null then null
    else "${bracketIfV6 host}:${toString port}";
in
{
  config = mkIf (cfg.tunnels != {}) (
    let
      tunnelsList = mapAttrsToList (tunnelName: tCfg:
        let
          iface = tCfg.interfaceName or (mkIfaceName tunnelName);
          rp = if tCfg.rpFilterMode == "loose" then 2
            else if tCfg.rpFilterMode == "strict" then 1
            else if tCfg.rpFilterMode == "off" then 0
            else null;
          keySource =
            if tCfg.privateKey.kind == "file"
              then { kind = "file"; file = tCfg.privateKey.path; }
              else { kind = "sops"; sopsFile = "${secretsRepo}/trove/${tCfg.privateKey.path}"; };
        in {
          name = tunnelName;
          inherit iface rp;
          addresses = tCfg.addresses;
          routes = tCfg.routes;
          listenPort = tCfg.listenPort;
          mtuBytes = tCfg.mtu;
          enableIPForward = tCfg.enableIPForward;
          masquerade = tCfg.masquerade;
          openFirewall = tCfg.openFirewall;
          keySource = keySource;
          secretName = mkSecretName tunnelName;
        }
      ) cfg.tunnels;

      netdevs = builtins.listToAttrs (map (t: {
        name = t.iface;
        value = {
          netdevConfig = { Kind = "wireguard"; Name = t.iface; };
          wireguardConfig =
            { PrivateKeyFile = if t.keySource.kind == "file" then t.keySource.file else "/run/secrets/${t.secretName}"; }
            // lib.optionalAttrs (t.listenPort != null) { ListenPort = t.listenPort; };
          wireguardPeers = []; # handled at runtime
        };
      }) tunnelsList);

      networks = builtins.listToAttrs (map (t: {
        name = t.iface;
        value = {
          matchConfig.Name = t.iface;
          networkConfig =
            optionalAttrs (t.enableIPForward or false) { IPv4Forwarding = true; }
            // optionalAttrs (t.masquerade != null) { IPMasquerade = t.masquerade; };
          linkConfig = optionalAttrs (t.mtuBytes != null) { MTUBytes = t.mtuBytes; };
          addresses = map (addr: { Address = addr; }) t.addresses;
          routes = t.routes;
        };
      }) tunnelsList);

      openedUDPPorts =
        lib.unique (lib.flatten (map (t:
          if t.openFirewall && t.listenPort != null then [ t.listenPort ] else [ ]
        ) tunnelsList));

      # Build the sysctl commands only for those ifaces that requested an override
      rpfCmds = lib.concatStringsSep "\n" (map (t:
        lib.optionalString (t.rp != null)
          ''${pkgs.sysctl}/bin/sysctl -w "net.ipv4.conf.${t.iface}.rp_filter=${toString t.rp}" || true''
      ) tunnelsList);

      secrets = builtins.listToAttrs (map (t:
        if t.keySource.kind == "sops" then {
          name = t.secretName;
          value = {
            sopsFile = t.keySource.sopsFile;
            format   = "binary";
            owner = "systemd-network";
            group = "systemd-network";
            mode  = "0400";
            restartUnits = [ "systemd-networkd.service" ];
          };
        } else null
      ) tunnelsList);
    in {
      # Handy while debugging; service also has curl/jq in its PATH
      environment.systemPackages = [ pkgs.wireguard-tools pkgs.curl pkgs.jq ];
      sops.secrets = lib.filterAttrs (_: v: v != null) secrets;

      systemd.network.netdevs  = netdevs;
      systemd.network.networks = networks;

      networking.firewall.allowedUDPPorts = openedUDPPorts;
      networking.firewall.trustedInterfaces = (map (t: t.iface) tunnelsList);
      
      systemd.services = lib.foldl' (acc: t:
        let
          iface = t.iface;
          tunnelName = t.name;
        in acc // {
          "wg-sync@${iface}" = {
            description = "Sync WireGuard peers for ${iface} from ${cfg.peerRegistryURL}";
            after = [ "network-online.target" "systemd-networkd.service" ];
            wants = [ "network-online.target" ];
            serviceConfig = { Type = "oneshot"; User = "root"; };
            path = [ pkgs.curl pkgs.jq pkgs.wireguard-tools pkgs.util-linux ];
            script = ''
              set -euo pipefail
              IFACE=${lib.escapeShellArg iface}
              URL=${lib.escapeShellArg cfg.peerRegistryURL}
              TUNNEL=${lib.escapeShellArg tunnelName}
              HOST=${lib.escapeShellArg thisHost}

              fetch() {
                curl -fsSL "$URL"
              }

              RAW="$(fetch)"

              rPeers="$(jq -c --arg T "$TUNNEL" '.tunnels[$T] // {}' <<<"$RAW")"
              myReg="$(jq -c --arg T "$TUNNEL" --arg H "$HOST" '.tunnels[$T][$H] // null' <<<"$RAW")"
              if [ "$myReg" = "null" ]; then
                echo "No registry entry for $HOST in tunnel $TUNNEL; skipping."
                exit 0
              fi

              # Identify a hub (any peer with endpoint+listenPort)
              hubName="$(
                jq -r '. | to_entries
                       | map(select(.value.endpoint!=null and .value.listenPort!=null))
                       | .[0].key // empty' <<<"$rPeers"
              )"

              # Are we a hub?
              iAmHub="$(
                jq -r 'select(.!=null) | ((.listenPort!=null) and (.endpoint!=null))' <<<"$myReg" || true
              )"
              [ -z "$iAmHub" ] && iAmHub="false"

              TMP="$(mktemp)"
              echo "[Interface]" > "$TMP"
              echo "PrivateKey = $(cat ${if (t.keySource.kind == "file") then t.keySource.file else "/run/secrets/${t.secretName}"})" >> "$TMP"
              # Optional if you want to set runtime; otherwise let networkd handle it at creation:
              ${lib.optionalString (t.listenPort or null != null) ''echo "ListenPort = ${toString t.listenPort}" >> "$TMP"''}
              echo "" >> "$TMP"

              # Choose peer set for this host:
              # - hub → everyone except self
              # - spoke → just the hub (if known), else everyone but self (fallback)
              peerNamesJSON="$(
                if [ "$iAmHub" = "true" ]; then
                  jq -c --arg H "$HOST" '. | keys | map(select(. != $H))' <<<"$rPeers"
                else
                  if [ -n "$hubName" ]; then
                    jq -c --arg hub "$hubName" '[ $hub ]' <<<"{}"
                  else
                    jq -c --arg H "$HOST" '. | keys | map(select(. != $H))' <<<"$rPeers"
                  fi
                fi
              )"

              myExtraAllowed="$(jq -c '.extraAllowedIPs // []' <<<"$myReg")"

              for peer in $(jq -r '.[]' <<<"$peerNamesJSON"); do
                p="$(jq -c --arg P "$peer" '.[$P]' <<<"$rPeers")"
                pub=$(jq -r '.publicKey' <<<"$p")
                epHost=$(jq -r '.endpoint // empty' <<<"$p")
                epPort=$(jq -r '.listenPort // empty' <<<"$p")

                if [ "$iAmHub" = "true" ]; then
                  allowed="$(jq -c '[.addresses[]?]
                                    | map(. | split("/")[0]
                                          + (if contains(":") then "/128" else "/32" end))' <<<"$p")"
                else
                  if [ -n "$hubName" ] && [ "$peer" = "$hubName" ]; then
                    allowed="$myExtraAllowed"
                  else
                    allowed="$(jq -c '[.addresses[]?]
                                      | map(. | split("/")[0]
                                            + (if contains(":") then "/128" else "/32" end))' <<<"$p")"
                  fi
                fi

                echo "[Peer]" >>"$TMP"
                echo "PublicKey = $pub" >>"$TMP"

                if [ -n "$epHost" ] && [ -n "$epPort" ]; then
                  if printf "%s" "$epHost" | grep -q ':'; then
                    echo "Endpoint = [$epHost]:$epPort" >>"$TMP"
                  else
                    echo "Endpoint = $epHost:$epPort" >>"$TMP"
                  fi
                  echo "PersistentKeepalive = 25" >>"$TMP"
                fi

                aList=$(jq -r 'join(",")' <<<"$allowed")
                [ -n "$aList" ] && echo "AllowedIPs = $aList" >>"$TMP"
                echo "" >>"$TMP"
              done

              wg setconf "$IFACE" "$TMP"
              rm -f "$TMP"
            '';
          };
        }
      )
      {}
      tunnelsList
      // lib.optionalAttrs (rpfCmds != "") {
        cauldron-wg-rpf = {
          description = "Set rp_filter on WireGuard router interfaces";
          after = [ "network-online.target" "systemd-networkd.service" ];
          requires = [ "systemd-networkd.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig.Type = "oneshot";
          # Re-run if WG config changes (iface / rp values)
          restartTriggers = [
            (pkgs.writeText "wg-rpf-trigger.json"
              (builtins.toJSON (map (t: { iface = t.iface; rp = t.rp; }) tunnelsList)))
          ];
          script = ''
            set -eu
            ${rpfCmds}
          '';
        };
      };
      
      systemd.timers = lib.foldl' (acc: t:
        let
          iface = t.iface;
        in acc // {
          "wg-sync@${iface}" = {
            description = "Timer: refresh peers for ${iface}";
            wantedBy = [ "timers.target" ];
            partOf = [ "wg-sync@${iface}.service" ];
            timerConfig = {
              OnBootSec = "10s";
              OnUnitActiveSec = cfg.pollInterval;
              AccuracySec = "2s";
            };
          };
        }
      )
      {}
      tunnelsList;
    }
  );
}


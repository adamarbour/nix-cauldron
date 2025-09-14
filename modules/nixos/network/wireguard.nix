{ lib, pkgs, config, sources, ... }:
let
  inherit (lib) mkOption mkEnableOption types mkIf mapAttrsToList attrNames filterAttrs optionalAttrs getAttrFromPath;
  secretsRepo = sources.secrets;
  cfg = config.cauldron.host.network.wireguard;
  reg = config.cauldron.registry.wireguard or {};
  thisHost = config.networking.hostName;

  mkSecretName = name: "wg-${name}-key";
  mkIfaceName  = name: "wg-${name}";
  # Compose Endpoint correctly for v4/v6
  mkEndpoint = host: port:
    if host == null || port == null then null
    else "${bracketIfV6 host}:${toString port}";
  
  # Detect IPv6
  isV6 = ip: lib.hasInfix ":" ip;

  # Turn "A.B.C.D/xx" -> "A.B.C.D/32" and IPv6 -> /128.
  # If no CIDR is present, assume host (/32 or /128) based on address family.
  hostCIDR = addr: let
    parts = lib.splitString "/" addr;
    ip    = builtins.elemAt parts 0;
    isV6  = lib.hasInfix ":" ip;
    mask  = if isV6 then "128" else "32";
  in "${ip}/${mask}";
  
  # Bracket IPv6 literal for Endpoint if needed:
  # "2001:db8::10" -> "[2001:db8::10]"
  bracketIfV6 = host: if isV6 host then "[${host}]" else host;
in {
  config = mkIf (cfg.tunnels != {}) (
    let      
      # Build a normalized list for all *configured* host tunnels, merging registry info.
      tunnelsList = mapAttrsToList (tunnelName: tCfg:
        let
          hubCandidates = lib.attrNames (filterAttrs (_: p: (p.endpoint or null) != null) rPeers);
          hubName = if hubCandidates != [] then builtins.head hubCandidates else null;
          # Determine if *this* node is the hub (robust if your registry tags it with endpoint+listenPort).
          iAmHub = myReg != null
            && (myReg.listenPort or null) != null
            && (myReg.endpoint or null) != null;
  
          iface = tCfg.interfaceName or (mkIfaceName tunnelName);
          enableIPForward = tCfg.enableIPForward;
          rp = if tCfg.rpFilterMode == "loose" then 2
            else if tCfg.rpFilterMode == "strict" then 1
            else if tCfg.rpFilterMode == "off" then 0
            else null;
          rPeers = (reg.tunnels or {}).${tunnelName} or {};
          myReg = (reg.tunnels or {}).${tunnelName}.${thisHost} or null;
          myExtraAllowed = if myReg == null then [] else (myReg.extraAllowedIPs or []);
          
          # Local interface addresses: prefer host config; else registry self
          myAddresses = if (tCfg.addresses or []) != [] then tCfg.addresses
            else if myReg != null then myReg.addresses else [];
          
          # Local listen port: prefer host config; else registry self
          myListenPort = if tCfg ? listenPort && tCfg.listenPort != null then tCfg.listenPort
            else if myReg != null then myReg.listenPort else null;
          
          # Per-tunnel defaults (e.g., mtu)
          tDefaults = (reg.defaults or {}).${tunnelName} or {};
          mtuBytes  = if tDefaults ? mtu then tDefaults.mtu else null;
          
          # Build peers: hub gets everyone; spokes get only the hub.
          peerNames = if iAmHub then lib.remove thisHost (attrNames rPeers)
            else if hubName != null then [ hubName ]
            else lib.remove thisHost (attrNames rPeers);
          
          peers = map (peerName:
            let
              p = rPeers.${peerName};
              isPeerHub = (hubName != null) && (peerName == hubName);
              peerHostRoutes = map hostCIDR (p.addresses or []);
              allowed = if iAmHub then peerHostRoutes
                else if isPeerHub then lib.unique myExtraAllowed
                else peerHostRoutes;
              endpointStr = mkEndpoint p.endpoint p.listenPort;
            in { PublicKey = p.publicKey; }
              // lib.optionalAttrs (allowed != []) { AllowedIPs = allowed; }
              // lib.optionalAttrs (endpointStr != null) { Endpoint = endpointStr; }
              // lib.optionalAttrs (endpointStr != null) { PersistentKeepalive = 25; }
          ) peerNames;
          
          # Key source (from your prior module)
          keySource = if tCfg.privateKey.kind == "file"
            then { kind = "file"; file = tCfg.privateKey.path; }
            else { kind = "sops"; sopsFile = "${secretsRepo}/trove/${tCfg.privateKey.path}"; };
        in {
          name = tunnelName;
          inherit iface rp keySource mtuBytes;
          enableIPForward = tCfg.enableIPForward;
          masquerade = tCfg.masquerade;
          addresses = myAddresses;
          routes = tCfg.routes;
          listenPort = myListenPort;
          openFirewall = tCfg.openFirewall;
          wireguardPeers = peers;
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
          wireguardPeers = t.wireguardPeers;
        };
      }) tunnelsList);
      
      networks = builtins.listToAttrs (map (t: {
        name = t.iface;
        value = {
          matchConfig.Name = t.iface;
          networkConfig = optionalAttrs (t.enableIPForward or false) { IPv4Forwarding = true; }
            // optionalAttrs (t.masquerade != null) { IPMasquerade = t.masquerade; };
          # Per-tunnel default MTU (if provided)
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
          ''${pkgs.kmod}/bin/sysctl -w "net.ipv4.conf.${t.iface}.rp_filter=${toString t.rp}" || true''
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
            restartUnits = mkIf cfg.restartOnChange [ "systemd-networkd.service" ];
          };
        } else null
      ) tunnelsList);
    in {
      # Only sops-based keys go into secrets
      sops.secrets = lib.filterAttrs (_: v: v != null) secrets;
      
      environment.systemPackages = [ pkgs.wireguard-tools ];

      systemd.network.netdevs  = netdevs;
      systemd.network.networks = networks;
      
      networking.firewall.allowedUDPPorts = openedUDPPorts;
      networking.firewall.trustedInterfaces = (map (t: t.iface) tunnelsList);
      
      systemd.services.cauldron-wg-rpf = mkIf (rpfCmds != "") {
        description = "Set rp_filter on WireGuard router interfaces";
        after = [ "network-online.target" "systemd-networkd.service" ];
        requires = [ "systemd-networkd.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "set-wg-rpf.sh" ''
            set -eu
            ${rpfCmds}
          '';
        };
        # Re-run if your WG config changes
        restartTriggers = [
          (pkgs.writeText "wg-rpf-trigger.json"
            (builtins.toJSON (map (t: { iface = t.iface; rp = t.rp; }) tunnelsList)))
        ];
      };
    }
  );
}

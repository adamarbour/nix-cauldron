{ lib, pkgs, config, sources, ... }:
let
  inherit (lib) mkOption mkEnableOption types mkIf mapAttrsToList attrNames filterAttrs optionalAttrs getAttrFromPath;
  secretsRepo = sources.secrets;
  cfg = config.cauldron.host.network.wireguard;
  reg = config.cauldron.registry.wireguard or {};
  thisHost = config.networking.hostName;

  mkSecretName = name: "wg-${name}-key";
  mkIfaceName  = name: "wg-${name}";
  
  # Turn "A.B.C.D/xx" -> "A.B.C.D/32" and IPv6 -> /128.
  # If no CIDR is present, assume host (/32 or /128) based on address family.
  hostCIDR = addr: let
    parts = lib.splitString "/" addr;
    ip    = builtins.elemAt parts 0;
    isV6  = lib.hasInfix ":" ip;
    mask  = if isV6 then "128" else "32";
  in "${ip}/${mask}";
in {
  config = mkIf (cfg.tunnels != {}) (
    let      
      # Build a normalized list for all *configured* host tunnels, merging registry info.
      tunnelsList = mapAttrsToList (tunnelName: tCfg:
        let
          iface = tCfg.interfaceName or (mkIfaceName tunnelName);
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
          
          # Build peers = all registry entries except self
          peerNames = lib.remove thisHost (attrNames rPeers);
          peers = map (peerName:
            let
              p = rPeers.${peerName};
              peerHostRoutes = map hostCIDR (p.addresses or []);
              allowed = lib.unique (peerHostRoutes ++ myExtraAllowed);
              endpointStr = if p.endpoint != null && p.listenPort != null then
                  "${p.endpoint}:${toString p.listenPort}"
                else if p.endpoint != null then
                  p.endpoint
                else null;
            in { PublicKey = p.publicKey; }
              // lib.optionalAttrs (allowed != []) { AllowedIPs = allowed; }
              // lib.optionalAttrs (endpointStr != null) { Endpoint = endpointStr; }
              // lib.optionalAttrs (p.persistentKeepalive != null) { PersistentKeepalive = p.persistentKeepalive; }
              // lib.optionalAttrs (endpointStr != null && p.persistentKeepalive == null) { PersistentKeepalive = 25; }
          ) peerNames;
          
          # Key source (from your prior module)
          keySource = if tCfg.privateKey.kind == "file"
            then { kind = "file"; file = tCfg.privateKey.path; }
            else { kind = "sops"; sopsFile = "${secretsRepo}/trove/${tCfg.privateKey.path}"; };
        in {
          name = tunnelName;
          inherit iface keySource mtuBytes;
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
          # Per-tunnel default MTU (if provided)
          linkConfig = lib.optionalAttrs (t.mtuBytes != null) { MTUBytes = t.mtuBytes; };
          addresses = map (addr: { Address = addr; }) t.addresses;
          routes = t.routes;
        };
      }) tunnelsList);
      
      openedUDPPorts =
        lib.unique (lib.flatten (map (t:
          if t.openFirewall && t.listenPort != null then [ t.listenPort ] else [ ]
        ) tunnelsList));
      
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
    }
  );
}

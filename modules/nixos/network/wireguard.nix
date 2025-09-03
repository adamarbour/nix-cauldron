{ lib, pkgs, config, sources, ... }:
let
  inherit (lib) types mkIf mkOption mkMerge mapAttrs mapAttrsToList attrValues nameValuePair optionalAttrs filterAttrs
    filter hasAttr;
  
  secretsEnabled = config.cauldron.secrets.enable or false;
  secretsRepo = sources.secrets;
  
  tunnels = config.cauldron.wireguard.tunnels or {};
  enableFor = config.cauldron.host.network.wireguard.enableFor or {};
    
  # Build WG netdev + network for one tunnel on this host
  mkTunnel = ifName: tcfg: hostCfg: let
    # Resolve where the private key is read from.
    keyFile = if (hostCfg.privateKey.kind or "file") == "sops" then
      "/run/secrets/${hostCfg.privateKey.path}"
      else hostCfg.privateKey.path;
    
    # Filter out our own pubkey from peers
    otherPeers = builtins.filter (p: (hostCfg.publicKey or "") != p.publicKey) (tcfg.peers or []);
    
    # Transform peers to systemd's WireGuardPeer sections
    peers = map (p: filterAttrs (_: v: v != null) {
      PublicKey = p.publicKey;
      AllowedIPs = p.allowedIPs or [];
      Endpoint = p.endpoint or null;
      PersistentKeepalive = p.persistentKeepalive or 25;
      PresharedKeyFile = p.presharedKeyFile or null;
    }) otherPeers;
    
    # Handle MTU if provided
    linkCfg = optionalAttrs (hostCfg.mtu != null) {
      MTUBytes = hostCfg.mtu;
    };
    
    # Optional extra routes
    extraRoutes = map (r: if builtins.isString r then { routeConfig.Destination = r; } else r) (hostCfg.routes or []);
  in {
    # NETDEV
    systemd.network.netdevs.${ifName} = {
      netdevConfig = { Kind = "wireguard"; Name = ifName; };
      wireguardConfig = filterAttrs (_: v: v != null) {
        PrivateKeyFile = keyFile;
        ListenPort = hostCfg.listenPort or null;
      };
      wireguardPeers = peers;
    };
    # NETWORK
    systemd.network.networks.${ifName} = {
      matchConfig.Name = ifName;
      address = hostCfg.addresses;
      dns = hostCfg.dns or [];
      routes = extraRoutes;
      routingPolicyRules = hostCfg.routingPolicyRules or [];
      linkConfig = linkCfg;
    };
  };
  
  # Build all tunnels selected for the host
  buildAll = mkMerge (mapAttrsToList (tname: hostCfg: let
    tcfg = tunnels.${tname};
  in mkTunnel tname tcfg hostCfg) enableFor);
    
  # Open inbound UDP ports for any selected interfaces
  selectedListenPorts = builtins.filter (x: x != null) (attrValues (mapAttrs (_n: hostCfg:
    if (hostCfg.openFirewall or false) && (hostCfg ? listenPort) then hostCfg.listenPort else null
  ) enableFor));
  
  # Assert all enabled tunnels actually exist in the registry
  missing = builtins.filter (tname: !(hasAttr tname tunnels)) (builtins.attrNames enableFor);
  
  # Declare sops.secrets for any interface using sops key files
  mkSopsSecretPivateKey = let
    sopsPeers = filterAttrs (_name: hostCfg: hostCfg.privateKeyFile.kind == "sops") enableFor;
  in lib.mapAttrs' (_iname: hostCfg: nameValuePair hostCfg.privateKeyFile.path {
    format = "binary";
    sopsFile = "${secretsRepo}/trove/" + hostCfg.privateKeyFile.path;
    mode = "0400";
  }) sopsPeers;
  
in {
  # NOTE: Different option paths because of how I want to configure and access.
  options.cauldron.wireguard.tunnels = mkOption {
    type = types.attrsOf (types.submodule ({name, ... }: {
      options = {
        description = mkOption { type = types.str; default = ""; };
        peers = mkOption {
          type = types.listOf (types.submodule {
            options = {
              name = mkOption { type = types.str; };
              publicKey = mkOption { type = types.str; };
              endpoint = mkOption { type = types.nullOr types.str; default = null; };
              allowedIPs = mkOption { type = types.listOf types.str; default = []; };
              persistentKeepalive = mkOption { types = types.nullOr types.int; default = 25; };
              presharedKeyFile = mkOption { type = types.nullOr types.path; default = null; };
            };
          });
          default = [];
        };
      };
    }));
    default = {};
    description = "Registry of tunnels and public peer info";
  };
  
  options.cauldron.host.network.wireguard.enableFor = mkOption {
    type = types.attrsOf (types.submodule ({ name, ... }: {
      options = {
        addresses = mkOption { type = types.nonEmptyListOf types.str; };
        privateKeyFile = mkOption {
          type = types.submodule {
            options = {
              kind = mkOption { type = types.enum [ "sops" "file" ]; default = "sops"; };
              path = mkOption {
                type = types.str;
                example = "wg/hostname.key";
                description = "If kind=\"sops\", this is the sops secret name; if kind=\"file\", an absolute path.";
              };
            };
          };
        };
        publicKey = mkOption { type = types.nullOr types.str; default = null; };
        listenPort = mkOption { type = types.nullOr types.int; default = null; };
        dns = mkOption { type = types.listOf types.str; default = []; };
        mtu = mkOption { type = types.nullOr types.int; default = null; };
        routes = mkOption { type = types.listOf (types.either types.str types.attrs); default = []; };
        routingPolicyRules = mkOption { type = types.listOf types.attrs; default = []; };
        openFirewall = mkOption { type = types.bool; default = false; };
      };
    }));
    default = {};
    description = "Per-host enablement + secrets and local settings.";
  };
  
  config = mkIf (enableFor != {}) (mkMerge [
    # Check for typos in tunnel names
    (mkIf (missing != []) {
      assertions = [{
        assertion = false;
        message = "Wireguard: cauldron.host.network.wirguard.enableFor references tunnel(s) "
          + toString missing
          + " that do not exist under cauldron.wireguard.tunnels.";
      }];
    })
    
    # Add minimums
    {
      boot.kernelModules = [ "wireguard" ];
      networking.firewall.allowedUDPPorts = selectedListenPorts;
      environment.systemPackages = [ pkgs.wireguard-tools ];
    }
    
    # Build the network configurations
    buildAll
    
    # Optionally enroll secrets
    (mkIf secretsEnabled {
      sops.secrets = mkSopsSecretPivateKey;
    })
  ]);
}

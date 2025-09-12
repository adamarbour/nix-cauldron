{ lib, pkgs, config, ... }:
let
  inherit (lib) types mkIf mkOption mkEnableOption;
  
  cfg = config.cauldron.services.transmission;
in {
  options.cauldron.services.transmission = {
    enable = mkEnableOption "Transmission bittorrent client";
    user = mkOption { type = types.str; default = "transmission"; };
    group = mkOption { type = types.str; default = "transmission"; };
    dataDir = mkOption { type = types.path; default = "/var/lib/transmission"; };
    downloadDir = mkOption { type = types.path; default = "${cfg.dataDir}/Downloads"; };
    incompleteDir = mkOption { type = types.path; default = "${cfg.downloadDir}/.incomplete"; };
    # Network
    torrentPort = mkOption { type = types.port; default = 51413; };
    # RPC
    rpcInterface = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        If set, RPC/WebUI bind only to the rpcBindIPv4 and the firewall allows the RPC 
        port only on that interface. If null, RPC binds to all interfaces ("0.0.0.0") 
        and firewall is NOT opened for RPC unless you opt in.
      '';
    };
    rpcPort = mkOption { type = types.port; default = 9091; };
    rpcBindIPv4 = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "10.7.0.2";
      description = "IPv4 address on rpcInterface to bind RPC to when rpcInterface is set.";
    };
    rpcReqAuth = mkOption {
      type = types.bool;
      default = true;
      description = "If true and wgInterface=null, set rpc-authentication-required = true unless overridden in extraSettings.";
    };
    # Perf
    cacheSize = mkOption {
      type = types.ints.positive;
      default = 64; # MiB
      description = "Transmission disk cache size in MiB (maps to settings.json: cache-size-mb).";
    };
    peerLimit = mkOption {
      type = types.ints.positive;
      default = 500;
      description = "Global peer limit (maps to settings.json: peer-limit-global).";
    };
    peerLimitPT = mkOption {
      type = types.ints.positive;
      default = 100;
      description = "Per-torrent peer limit (maps to settings.json: peer-limit-per-torrent).";
    };
    extraSettings = mkOption {
      type = types.attrs;
      default = {};
      description = "Merged into Transmission settings.json (last-wins).";
    };
  };
  
  config = let configDir = "${cfg.dataDir}/.config/transmission-daemon";
  in mkIf cfg.enable {
    assertions = [{
      assertion = (cfg.rpcInterface != null) || (cfg.wgAddressIPv4 != null);
      message = "cauldron.services.transmission.rpcBindIPv4 must be set when rpcInterface is set.";
    }];
    
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.dataDir;
    };
    users.groups.${cfg.group} = {};
    
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir}         0750 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.dataDir}/.config 0750 ${cfg.user} ${cfg.group} - -"
      "d ${configDir}       0750 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.downloadDir}     2755 ${cfg.user} ${cfg.group} - -"
      "d ${cfg.incompleteDir}   2755 ${cfg.user} ${cfg.group} - -"
    ];
    
    services.transmission = {
      enable = true;
      package = pkgs.transmission_4;
      webHome = pkgs.flood-for-transmission;
      user = cfg.user;
      group = cfg.group;
      home = cfg.dataDir;
      
      settings = {
        umask = "002";
        download-dir = cfg.downloadDir;
        incomplete-dir-enabled = true;
        incomplete-dir = "${cfg.downloadDir}/.incomplete";
        peer-port = cfg.torrentPort;
        peer-port-random-on-start = false;
        
        # RPC
        "rpc-enabled" = true;
        rpc-port = cfg.rpcPort;
        rpc-bind-address = if cfg.rpcBindIPv4 != null then cfg.rpcBindIPv4 else "0.0.0.0";
        "rpc-authentication-required" = cfg.rpcReqAuth;
        "rpc-whitelist-enabled" = false;
        
        # Networking
        "port-forwarding-enabled" = false;
        utp-enabled = true;
        "dht-enabled" = true;
        "lpd-enabled" = false;
        "pex-enabled" = true;
        
        # Performance
        "cache-size-mb" = cfg.cacheSize;
        "peer-limit-global" = cfg.peerLimit;
        "peer-limit-per-torrent" = cfg.peerLimitPT;
      } // cfg.extraSettings;
    };
    
    # Expose torrenting...
    networking.firewall.allowedTCPPorts = [ cfg.torrentPort ];
    networking.firewall.allowedUDPPorts = [ cfg.torrentPort ];
    
    # Expose RPC/web ui
    networking.firewall.interfaces = mkIf (cfg.rpcInterface != null) {
      ${cfg.rpcInterface}.allowedTCPPorts = [ cfg.rpcPort ];
    };
    
    # Service modifications/hardening
    systemd.services.transmission.serviceConfig = {
      User  = cfg.user;
      Group = cfg.group;
      # Core sandboxing
      NoNewPrivileges = true;
      PrivateTmp = true;
      PrivateDevices = true;
      PrivateIPC = true;
      ProtectSystem = "strict";
      ProtectHome = "read-only";
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectControlGroups = true;
      ProtectHostname = true;
      ProtectClock = true;
      RestrictSUIDSGID = true;
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      RestrictRealtime = true;
      RestrictNamespaces = true;
      # Keep only the network families it actually needs
      RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
      # Don’t grant any capabilities (no privileged ports needed)
      CapabilityBoundingSet = "";
      AmbientCapabilities = "";
      # Nice-to-have limits for lots of peers/files
      LimitNOFILE = 65536;
      # Ensure mounts exist before starting (pairs well with impermanence)
      RequiresMountsFor = [ configDir cfg.dataDir cfg.downloadDir cfg.incompleteDir ];
      ReadWritePaths = [ configDir cfg.dataDir cfg.downloadDir cfg.incompleteDir ];
    };
    systemd.services.transmission.after = [ "network-online.target" ]
      ++ lib.optionals (cfg.rpcInterface != null) [ "${cfg.rpcInterface}.device" ];
    systemd.services.transmission.requires = [ "network-online.target" ];
  };
}

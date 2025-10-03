{ lib, pkgs, config, ... }:
let
  inherit (lib) types mkIf mkEnableOption;
  
  netName = cfg.name;
  
  cfg = config.cauldron.services.innernet;
in {
  options.cauldron.services.innernet = with types; {
    package = mkOption {
      type = package;
      default = pkgs.innernet;
      defaultText = "pkgs.innernet";
      description = "The package to use for innernet";
    };
    name = mkOption {
      type = str;
      default = "innernet0";
      description = "Overlay network name (becomes innernet@<name>).";
    };
    configDir = mkOption {
      type = path;
      default = "/etc/innernet";
      description = "Directory for client configs (invitation TOML installs land here).";
    };
    stateDir = mkOption {
      type = path;
      default = "/var/lib/innernet";
      description = "Server state directory (SQLite DB, keys, etc.).";
    };
    # SERVER
    server = {
      enable = mkEnableOption "Run innernet registry (innernet-server).";
      listenPort = mkOption {
        type = port;
        default = 51820;
        description = "UDP port for the innernet server's WireGuard endpoint.";
      };
      publicEndpoint = mkOption {
        type = nullOr str;
        default = null;
        description = "Optional public endpoint (host:port) to advertise when initializing network.";
      };
      extraArgs = mkOption {
        type = listOf str;
        default = [ ];
        description = "Extra args to pass to innernet-server serve.";
      };
    };
    # CLIENT
    client = {
      enable = mkEnableOption "Run innernet client (peer).";
      autoStart = mkOption {
        type = bool;
        default = true;
        description = "Start client at boot (after network-online.target).";
      };
      fetchOnReload = mkOption {
        type = bool;
        default = true;
        description = "systemctl reload will `innernet fetch <if>` to refresh peers.";
      };
    };
  };
  
  config = mkIf (cfg.server.enable || cfg.client.enable) {
    boot.kernel.sysctl = mkIf (cfg.servers != {}) {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
    
    environment.systemPackages = [ cfg.package pkgs.wireguard-tools ];
    systemd.tmpfiles.rules = [
      "d ${cfg.configDir} 0755 root root -"
      "d ${cfg.stateDir}  0700 root root -"
    ];
    
    networking.wireguard.enable = true;
    networking.firewall = mkIf cfg.server.enable {
      allowedUDPPorts = [ cfg.server.listenPort ];
    };
    
    ### Server unit
    systemd.services."innernet-server@${netName}" = mkIf cfg.server.enable {
      description = "innernet registry server (${netName})";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      requires = [ "network-online.target" ];
      serviceConfig = {
        DynamicUser = false; # needs stable state dir
        ExecStart = ''
          ${lib.getExe' cfg.package "innernet-server"} serve ${netName} \
            --state-dir ${cfg.stateDir} ${lib.concatStringsSep " " cfg.server.extraArgs}
        '';
        WorkingDirectory = cfg.stateDir;
        Restart = "on-failure";
        CapabilityBoundingSet = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
        AmbientCapabilities = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
      };
    };
    
    ### Client unit
    systemd.services."innernet@${netName}" = mkIf cfg.client.enable {
      description = "innernet client (${netName})";
      wantedBy = lib.optionals cfg.client.autoStart [ "multi-user.target" ];
      after = [ "network-online.target" ];
      requires = [ "network-online.target" ];
      environment = {
        XDG_CONFIG_HOME = cfg.configDir; # innernet reads configs from here
      };
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${lib.getExe cfg.package} up ${netName}";
        ExecStop = "${lib.getExe cfg.package} down ${netName}";
        ExecReload = mkIf cfg.client.fetchOnReload "${lib.getExe cfg.package} fetch ${netName}";
        Restart = "on-failure";
        RuntimeDirectory = "innernet-${netName}";
        CapabilityBoundingSet = "CAP_NET_ADMIN";
        AmbientCapabilities = "CAP_NET_ADMIN";
      };
    };
    
        
  };
}

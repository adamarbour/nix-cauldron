{ lib, pkgs, config, ... }:
let
  inherit (lib) types mkIf mkMerge mkEnableOption mkOption;
  netName = "innernet." + cfg.name;
  
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
    privateKeyFile = mkOption {
      type = path;
      description = "The path to the private key file";
      example = "/run/secrets/server-private-key";
    };
    publicKey = mkOption {
      type = str;
      description = "The public key of the server";
      example = "wLKnL8rBNdSV7HBeuJLS6inBsqbqEwCexN+6jAbMfxk=";
    };
    # SERVER
    server = {
      enable = mkEnableOption "Run innernet registry (innernet-server).";
      configDir = mkOption {
        type = path;
        default = "/etc/innernet-server";
        description = "Directory for client configs (invitation TOML installs land here).";
      };
      stateDir = mkOption {
        type = path;
        default = "/var/lib/innernet-server";
        description = "Server state directory (SQLite DB, keys, etc.).";
      };
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
      cidr = mkOption {
        type = str;
        description = "The network cidr of the root network";
        example = "10.100.0.0/16";
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
      fetchOnReload = mkOption {
        type = bool;
        default = true;
        description = "systemctl reload will `innernet fetch <if>` to refresh peers.";
      };
      fetchInterval = mkOption {
        type = int;
        default = 25;
        example = "25";
        description = "How often to refresh peers from server";
      };
    };
  };
  
  config = mkIf (cfg.server.enable || cfg.client.enable) {
    boot.kernel.sysctl = mkIf (cfg.server != {}) {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };
    
    environment.systemPackages = [ cfg.package pkgs.wireguard-tools ];
    systemd.tmpfiles.rules = []
    ++ lib.optionals (cfg.server.enable) [
      "d ${cfg.server.configDir} 0400 root root -"
      "d ${cfg.server.stateDir}  0400 root root -"
    ] ++ lib.optionals (cfg.client.enable) [
      "d ${cfg.client.configDir} 0400 root root -"
      "d ${cfg.client.stateDir}  0400 root root -"
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
      path = [ pkgs.iproute2 ];
      environment = {
        RUST_LOG = "info";
      };
      serviceConfig = {
        ExecStartPre = pkgs.writeShellScript "innernet-systemd-server-pre-${netName}" ''
          rm -f ${cfg.server.configDir}/${netName}.conf ${cfg.server.stateDir}/${netName}.db
          ${lib.getExe' cfg.package "innernet-server"} new \
            --network-name "${netName}" \
            --network-cidr "${cfg.server.cidr}" \
            --external-endpoint "${cfg.server.publicEndpoint}" \
            --listen-port ${toString cfg.server.listenPort} >/dev/null
          PKEY="$(cat ${cfg.privateKeyFile})"
          export PKEY
          sed -i "s|private-key =.*|private-key = \"$PKEY\"|g" ${cfg.server.configDir}/${netName}.conf
          cat<<SQL | ${pkgs.sqlite}/bin/sqlite3 ${cfg.server.stateDir}/${netName}.db
            UPDATE peers
            SET public_key = '${cfg.publicKey}'
            WHERE name = 'innernet-server';
          SQL
        '';
        ExecStart = ''
          ${lib.getExe' cfg.package "innernet-server"} \
            --config-dir ${cfg.server.configDir} --data-dir ${cfg.server.stateDir} \
            serve ${netName}
        '';
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
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = ''
          ${lib.getExe cfg.package} \
            --config-dir ${cfg.client.configDir} --data-dir ${cfg.client.stateDir} \
            up -d --no-write-hosts --interval ${cfg.client.fetchInterval} ${netName}
        '';
        ExecStop = ''
          ${lib.getExe cfg.package} \
            --config-dir ${cfg.client.configDir} --data-dir ${cfg.client.stateDir} \
            down ${netName}
        '';
        ExecReload = mkIf cfg.client.fetchOnReload ''
          ${lib.getExe cfg.package} \
            --config-dir ${cfg.client.configDir} --data-dir ${cfg.client.stateDir} \
            fetch --no-write-hosts ${netName}
        '';
        Restart = "on-failure";
        CapabilityBoundingSet = "CAP_NET_ADMIN";
        AmbientCapabilities = "CAP_NET_ADMIN";
      };
    };
    
        
  };
}

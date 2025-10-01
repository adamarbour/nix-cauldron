{ lib, pkgs, config, ... }:
let
  inherit (lib) types mkIf mkEnableOption mkOption mdDoc optionalString;
  cfg = config.cauldron.services.innernet;
in {
  options.cauldron.services.innernet = {
    enable = mkEnableOption "Enable innernet overlay VPN on this host";
    package = mkOption {
      type = types.package;
      default = pkgs.innernet;
      description = "innernet package to use.";
    };
    role = mkOption {
      type = types.enum [ "server" "client" ];
      default = "client";
      description = mdDoc ''
        Choose "server" for the registry + public WireGuard endpoint,
        or "client" for peers behind NAT/Wi-Fi routers.
      '';
    };
    networkName = mkOption {
      type = types.str;
      default = "arbour-cloud";
      description = "The innernet network/interface name.";
    };
    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/innernet";
      description = "State dir for server DB and peer state.";
    };
    configDir = mkOption {
      type = types.path;
      default = "/etc/innernet";
      description = "Directory for innernet *.toml configs.";
    };
    server = {
      listenPort = mkOption {
        type = types.port;
        default = 51820;
        description = "UDP port the server listens on (expose in cloud firewall).";
      };
      openFirewall = mkOption {
        type = types.bool;
        default = true;
        description = "Open the UDP listenPort in the NixOS firewall.";
      };
      bootstrap = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = mdDoc ''
            If enabled, run a one-time idempotent bootstrap script at activation to create
            the network on first boot. This avoids the interactive wizard.
            You must provide at least rootCIDR; optionally also provide additional CIDRs and an admin peer.
          '';
        };
        rootCIDR = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "172.31.0.0/16";
          description = "Root CIDR to create during bootstrap (required if bootstrap.enable).";
        };
        extraCIDRs = mkOption {
          type = types.listOf (types.submodule {
            options = {
              name = mkOption { type = types.str; description = "CIDR name"; };
              cidr = mkOption { type = types.str; description = "CIDR range (e.g., 10.71.10.0/24)"; };
            };
          });
          default = [];
          example = [
            { name = "devices"; cidr = "10.71.10.0/24"; }
          ];
          description = "Additional CIDRs to create on bootstrap.";
        };
        adminPeerName = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "Admin peer to create on bootstrap (invitation file will be written if set).";
        };
        invitationDir = mkOption {
          type = types.nullOr types.path;
          default = "${cfg.dataDir}/invites";
          description = "Directory to write invitations during bootstrap (if adminPeerName set).";
        };
      };
    };
    client = {
      invitationFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = mdDoc ''
          Path to an invitation TOML for this host (optional). If provided, the module
          will idempotently run `innernet install` on first boot to create the local config.
        '';
      };
      persistentKeepaliveSeconds = mkOption {
        type = types.int;
        default = 25;
        description = "Default PersistentKeepalive used by innernet for NAT traversal (typical: 25).";
      };
    };
    hardenUnits = mkOption {
      type = types.bool;
      default = true;
      description = "Apply a set of systemd hardening options to innernet services.";
    };
  };
  
  config = mkIf cfg.enable (let
    dbPath = "${cfg.dataDir}/${cfg.networkName}.db";
    
    serviceHardening = mkIf cfg.hardenUnits {
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "strict";
      ProtectHome = true;
      ProtectControlGroups = true;
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      SystemCallFilter = [ "@system-service" ];
    };
  in {
    environment.systemPackages = [ cfg.package pkgs.wireguard-tools ];
    
    networking.firewall.allowedUDPPorts = mkIf (cfg.role == "server" && cfg.server.openFirewall) [ cfg.server.listenPort ];
    
    systemd.tmpfiles.rules = [
      "d ${cfg.dataDir} 0750 root root -"
      "d ${cfg.configDir} 0750 root root -"
    ];
    
    # TODO: Handle impermanence for db file on server and config files on client
    
    # One-shot activation hooks (Server)
    system.activationScripts.innernetServerBootstrap = mkIf (cfg.role == "server" && cfg.server.bootstrap.enable) {
      deps = [ ];
      # Bootstrap script (server only, optional). Runs on activation; checks for DB.
      text = optionalString (cfg.role == "server" && cfg.server.bootstrap.enable)
      ''
        #!/usr/bin/env bash
        set -euo pipefail
        
        mkdir -p ${lib.escapeShellArg cfg.dataDir} ${lib.escapeShellArg cfg.configDir}
        mkdir -p ${lib.escapeShellArg cfg.server.bootstrap.invitationDir}
        
        if [ ! -f ${lib.escapeShellArg dbPath} ]; then
          echo "[innernet] First-time bootstrap: creating network ${cfg.networkName}"
          ${lib.getExe cfg.package}-server new <<'EOF'
            ${cfg.networkName}
            ${cfg.server.bootstrap.rootCIDR}
            ${toString cfg.server.listenPort}
            ${cfg.configDir}
            ${cfg.dataDir}
          EOF
          
          # Extra CIDRs
          ${lib.concatStringsSep "\n" (map (c:
            "${lib.getExe cfg.package}-server add-cidr ${lib.escapeShellArg cfg.networkName} --name ${lib.escapeShellArg c.name} --cidr ${lib.escapeShellArg c.cidr}"
          ) cfg.server.bootstrap.extraCIDRs)}
          
          # Create an admin peer + invitation if requested
          ${lib.optionalString (cfg.server.bootstrap.adminPeerName != null) ''
            if ! ${lib.getExe cfg.package}-server list-peers ${lib.escapeShellArg cfg.networkName} | grep -q "^${cfg.server.bootstrap.adminPeerName}\b"; then
              ${lib.getExe cfg.package}-server add-peer ${lib.escapeShellArg cfg.networkName} \
                --name ${lib.escapeShellArg cfg.server.bootstrap.adminPeerName} \
                --admin \
                --invite-out ${lib.escapeShellArg cfg.server.bootstrap.invitationDir}
            fi
          ''}
          
          echo "[innernet] Bootstrap complete."
        else
          echo "[innernet] DB exists (${dbPath}); bootstrap skipped."
        fi
      '';
    };
    
    
    
    # Server unit (registry + Wireguard)
    systemd.services."innernet-server@${cfg.networkName}" = mkIf (cfg.role == "server") {
      description = "innernet registry and WireGuard (${cfg.networkName})";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package}-server serve ${cfg.networkName}";
        Restart = "on-failure";
        AmbientCapabilities = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
        CapabilityBoundingSet = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE";
      } // serviceHardening;
      wantedBy = [ "multi-user.target" ];
      # Ensure directories exist before start
      preStart = ''
        install -d -m 0750 -o root -g root ${cfg.dataDir} ${cfg.configDir}
      '';
    };
    
    # Client unit (peer Wireguard)
    systemd.services."innernet@${cfg.networkName}" = mkIf (cfg.role == "client") {
      description = "innernet peer (${cfg.networkName})";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        ExecStart = "${lib.getExe cfg.package} up ${cfg.networkName}";
        Restart = "on-failure";
        AmbientCapabilities = "CAP_NET_ADMIN";
        CapabilityBoundingSet = "CAP_NET_ADMIN";
      } // serviceHardening;
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        install -d -m 0750 -o root -g root ${cfg.configDir}
      '';
    };
  });
}

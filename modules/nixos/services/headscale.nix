{ lib, pkgs, config, ... }:
let
  inherit (lib) types mkIf mkMerge mkEnableOption mkOption;
  
  cfg = config.cauldron.services.headscale;
in {
  options.cauldron.services.headscale = with types; {
    enable = mkEnableOption "Enable Headscale server and Headplane UI";
    domain = mkOption {
      type = str;
      example = "headscale.example.com";
      description = "Domain name for Headscale and Headplane access.";
    };
    adminEmail = mkOption {
      type = str;
      default = "admin@localhost";
      description = "Email for Caddy certificate registration.";
    };
  };
  
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.headscale
    ];
    networking.firewall.allowedUDPPorts = [3478 41641];
    networking.firewall.allowedTCPPorts = [80 443];
  
    services.headscale = {
      enable = true;
      address = "0.0.0.0";
      port = 8080;
      
      settings = {
        server_url = "https://${cfg.domain}:443";
        logtail.enabled = false;
        listen_addr = "0.0.0.0:8080";
        grpc_listen_addr = "0.0.0.0:50443";
        private_key_path = "/var/lib/headscale/private.key";
        noise.private_key_path = "/var/lib/headscale/noise_private.key";
        dns = {
          override_local_dns = true;
          base_domain = "internal.${cfg.domain}";
          magic_dns = true;
          nameservers.global = [
            "9.9.9.9"
            "149.112.112.112"
            "2620:fe::fe"
            "2620:fe::9"
          ];
        };
        metrics_listen_addr = "127.0.0.1:9090";
        derp = {
          enabled = true;
          region_id = 999;
          region_code = "cauldron";
          region_name = "Cauldron DERP";
          stun_listen_addr = "0.0.0.0:3478";
          auto_update_enabled = true;
          automatically_add_embedded_derp_region = true;
          update_frequency = "5m";
        };
      };
    };
    
    services.caddy = {
      enable = true;
      email = cfg.adminEmail;
      virtualHosts = {
        "${cfg.domain}" = {
          extraConfig = ''
            reverse_proxy localhost:${toString config.services.headscale.port}
          '';
        };
      };
    };
  };
}

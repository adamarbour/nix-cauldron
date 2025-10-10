{ pkgs, ... }:
{
  cauldron = {
    profiles = [
      "gaming"
      "desktop"
      "graphical"
    ];
    
    host = {
      boot = {
        loader = "systemd";
        silentBoot = true;
      };
      disk = {
        enable = true;
        rootFs = "ext4";
        device = "/dev/nvme1n1";
        impermanence = {
          enable = true;
          rootSize = "1G";
        };
        swap.enable = true;
      };
      hardware = {
        cpu = "intel";
        gpu = "nvidia";
      };
      network = {
        wireless.backend = "wpa_supplicant";
      };
      impermanence = {
        root = "/persist";
      };
    };
    
    services = {
      tailscale.enable = true;
      nebula = {
        enable = true;
        name = "cloud";
        hostname = "lucien";
        cidr = "10.24.13.212/24";
        lighthouses = [ "10.24.13.254" ];
        staticHostMap = {
          "10.24.13.254" = [ "157.137.184.33:4242" "wg.arbour.cloud:4242" ];
        };
        groups = [ "home" ];
        secrets = {
          ca = "/run/secrets/nebula_ca/ca";
          cert = "/run/secrets/nebula/crt";
          key = "/run/secrets/nebula/key";
        };
        allowAll = true;
      };
    };
    
    secrets = {
      enable = true;
      items = {
        "wg-key" = {
          sopsFile = "trove/wg/lucien.key";
          format = "binary";
        };
        "nebula_ca/ca" = {
          key = "nebula_ca/cert";
          owner = "nebula-cloud"; group = "nebula-cloud"; mode = "0400";
        };
        "nebula/crt" = {
          sopsFile = "trove/hosts/lucien.yaml";
          key = "nebula/crt";
          owner = "nebula-cloud"; group = "nebula-cloud"; mode = "0400";
        };
        "nebula/key" = {
          sopsFile = "trove/hosts/lucien.yaml";
          key = "nebula/key";
          owner = "nebula-cloud"; group = "nebula-cloud"; mode = "0400";
        };
      };
    };
  };
  
  # Enable the GNOME Desktop Environment.
  services.xserver.desktopManager.gnome.enable = true;
}

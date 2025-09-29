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
      innernet = {
        client.arbour-cloud = {
          enable = true;
          settings = {
            interface = { address = "172.31.1.212/24"; privateKeyFile = "/run/secrets/wg-key"; };
            server = { 
              publicKey = "jJZSbRd/g4hKLSoNkyT0p+kFNVJOA/UTaAXS4ikmT3s=";
              externalEndpoint = "40.233.13.66:51820";
              internalEndpoint = "172.31.0.1:51820";
            };
          };
        };
      };
    };
     secrets = {
      enable = true;
      items = {
        "wg-key" = {
          sopsFile = "trove/wg/lucien.key";
          format = "binary";
        };
      };
    };
  };
  
  # Enable the GNOME Desktop Environment.
  services.xserver.desktopManager.gnome.enable = true;
}

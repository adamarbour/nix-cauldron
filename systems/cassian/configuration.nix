{ pkgs, sources, ... }:
{
  cauldron = {
    profiles = [
      "graphical"
      "laptop"
      "workstation"
      "gaming"
    ];
    host = {
      boot = {
        loader = "secure";
        silentBoot = true;
      };
      hardware = {
        cpu = "intel";
        gpu = "hybrid";
      };
      network = {
        wireless.backend = "wpa_supplicant";
      };
      feature = {
        crossbuild = {
          enable = true;
          emulatedSystems = [ "aarch64-linux" ];
          extraPlatforms = [ "i686-linux" "aarch64-linux" ];
        };
        printing.enable = true;
        bluetooth = true;
        thunderbolt = true;
        tpm = true;
        winbox = true;
      };
    };
    services = {
      innernet = {
        client.arbour-cloud = {
          enable = true;
          settings = {
            interface = { address = "172.31.1.213/24"; privateKeyFile = "/run/secrets/wg-key"; };
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
          sopsFile = "trove/wg/cassian.key";
          format = "binary";
        };
      };
    };
  };

  # Enable the GNOME Desktop Environment.
  services.xserver.desktopManager.gnome.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

}

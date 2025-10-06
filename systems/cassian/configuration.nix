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
      tailscale.enable = true;
      nebula = {
        enable = true;
        name = "cloud";
        hostname = "cassian";
        cidr = "10.24.13.100/24";
        lighthouses = [ "10.24.13.254" ];
        staticHostMap = {
          "10.24.13.254" = [ "157.137.184.33:4242" ];
        };
        groups = [ "admin" ];
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
          sopsFile = "trove/wg/cassian.key";
          format = "binary";
        };
        "nebula_ca/ca" = {
          key = "nebula_ca/cert";
          owner = "nebula-cloud"; group = "nebula-cloud"; mode = "0400";
        };
        "nebula/crt" = {
          sopsFile = "trove/hosts/cassian.yaml";
          key = "nebula/crt";
          owner = "nebula-cloud"; group = "nebula-cloud"; mode = "0400";
        };
        "nebula/key" = {
          sopsFile = "trove/hosts/cassian.yaml";
          key = "nebula/key";
          owner = "nebula-cloud"; group = "nebula-cloud"; mode = "0400";
        };
      };
    };
  };

  # Enable the GNOME Desktop Environment.
  services.xserver.desktopManager.gnome.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

}

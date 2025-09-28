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

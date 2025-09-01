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
        tailscale.enable = true;
        wireless.backend = "wpa_supplicant";
      };
      feature = {
        printing.enable = true;
        bluetooth = true;
        thunderbolt = true;
        tpm = true;
        winbox = true;
      };
    };
    secrets.enable = true;
  };

  # Enable the GNOME Desktop Environment.
  services.xserver.desktopManager.gnome.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

}

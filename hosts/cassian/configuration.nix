{ pkgs, ... }:
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
        kernel = pkgs.unstable.linuxPackages_6_15;
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
      feature.mlnx-ofed = true;
    };
    secrets.enable = true;
  };
  

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

}

{ pkgs, ... }:
{
  cauldron = {
    profiles = [
      "graphical"
      "gaming"
    ];
    host = {
      boot = {
        kernel = pkgs.unstable.linuxPackages_6_16;
        loader = "systemd";
        silentBoot = true;
      };
      hardware = {
        cpu = "intel";
        gpu = "nvidia";
      };
      network = {
        tailscale.enable = true;
      };
    };
    secrets.enable = false;
  };
  services.flatpak.enable = false;
  
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Install firefox.
  programs.firefox.enable = true;
}

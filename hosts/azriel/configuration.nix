{ pkgs, sources, ... }:
{
  cauldron = {
    profiles = [
      "desktop"
      "graphical"
    ];
    host = {
      boot = {
        loader = "systemd";
        silentBoot = true;
      };
      hardware = {
        cpu = "intel";
        gpu = "intel";
      };
      disk = {
        enable = true;
        rootFs = "ext4";
        device = "/dev/mmcblk0";
        impermanence = {
          enable = true;
          rootSize = "1G";
        };
        swap.enable = true;
      };
      network = {
        wireless.backend = "wpa_supplicant";
        tailscale.enable = true;
      };
      feature = {
        touchscreen = {
          enable = true;
          includeTools = true;
          stylus.enable = true;
        };
        printing.enable = true;
        bluetooth = true;
        tpm = true;
      };
    };
    secrets.enable = false;
  };

  # Enable the GNOME Desktop Environment.
  services.xserver.desktopManager.gnome.enable = true;

}

{ pkgs, sources, ... }:
{
  cauldron = {
    profiles = [
      "graphical"
      "laptop"
      "workstation"
    ];
    host = {
      boot = {
        kernel = pkgs.linuxPackages_zen;
        loader = "systemd";
        silentBoot = true;
      };
      hardware = {
        cpu = "amd";
        gpu = "amd";
      };
      disk = {
        enable = true;
        encrypt = true;
        rootFs = "btrfs";
        device = "/dev/nvme0n1";
        impermanence = {
          enable = true;
          rootSize = "2G";
        };
      };
      network = {
        wireless.backend = "iwd";
      };
      feature = {
        touchscreen = {
          enable = true;
          sensors = true;
        };
        fprint.enable = true;
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

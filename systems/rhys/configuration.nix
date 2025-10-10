{ pkgs, sources, ... }:
{
  cauldron = {
    profiles = [ "gaming" "desktop" "graphical" "workstation" ];
    
    host = {
      boot = {
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
        printing.enable = true;
        bluetooth = true;
        tpm = true;
      };
    };

    secrets.enable = false;
  };

  # Enable the GNOME Desktop Environment.
  services.xserver.desktopManager.gnome.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

}

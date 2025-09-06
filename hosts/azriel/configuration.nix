{ pkgs, sources, ... }:
{
  cauldron = {
    profiles = [
      "desktop"
      "graphical"
      "workstation"
    ];
    host = {
      boot = {
        loader = "systemd";
        addKernelParams = [
          "rootdelay=15"
          "mmc_core.removable=0" 
          "mmc_block.perdev_minors=16"
        ];
        addKernelModules = [ "mmc_core" "mmc_block" ];
        addAvailKernelModules = [ "mmc_core" "mmc_block" "sdhci" "sdhci_pci" "sdhci_acpi" ];
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

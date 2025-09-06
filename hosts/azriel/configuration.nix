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
        addKernelParams = [
          "video=DP-1:3840x2160@60e"
          "usbhid.quirks=0x2fe9:0x4103:0x40"
          "usbhid.quirks=0x2fe9:0x0203:0x40"
        ];
        addKernelModules = [ "mmc_block" "hid_elo" ];
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

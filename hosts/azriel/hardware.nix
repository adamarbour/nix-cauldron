{ pkgs, ... }:
{
  cauldron.host.boot = {
    addKernelParams = [
      "i915.enable_guc=2"
      "video=DP-1:3840x2160@60e"
    ];
    addKernelModules = [ "mmc_block" ];
    addAvailKernelModules = [ "mmc_core" "mmc_block" "sdhci" "sdhci_pci" "sdhci_acpi" "i2c_designware_pci" "i2c_designware_platform" ];
  };
  
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="2FE9", TEST=="power/control", ATTR{power/control}="on"
  '';
}

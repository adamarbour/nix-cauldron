{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf;
  profiles = config.cauldron.profiles;
in {
  config = mkIf (lib.elem "laptop" profiles) {
    # Enable powersave on wifi
    # Set PCI runtime power management
    # USB autosuspend
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="net", KERNEL=="wlan*", RUN+="${pkgs.iw}/bin/iw dev %k set power_save on"
      
      SUBSYSTEM=="pci", ATTR{power/control}="auto"
      SUBSYSTEM=="ata_port", KERNEL=="ata*", ATTR{device/power/control}="auto"
      
      ACTION=="add", SUBSYSTEM=="usb", ATTR{product}!="*Mouse", ATTR{product}!="*Keyboard", TEST=="power/control", ATTR{power/control}="auto"
    '';
  };
}

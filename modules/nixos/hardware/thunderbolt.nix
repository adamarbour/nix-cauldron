{ lib, pkgs, config, ...}:
let
  inherit (lib) types mkIf mkOption;
  cfg = config.cauldron.host.feature;
  profiles = config.cauldron.profiles;
in {

  options.cauldron.host.feature.thunderbolt = mkOption {
    type = types.bool;
    default = false;
    description = "Wether to enable thunderbolt docking support";
  };
  
  config = mkIf cfg.thunderbolt {
    services.hardware.bolt.enable = true;
    services.udev.packages = [ pkgs.bolt ];
    services.logind = {
      lidSwitchDocked = "ignore";
    };
    boot = {
      initrd.availableKernelModules = [ "thunderbolt" ];
      kernelParams = [ "usbcore.autosuspend=-1" ];
    };
  };
}

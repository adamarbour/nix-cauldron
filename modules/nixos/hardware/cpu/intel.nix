{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf;
  cfg = config.cauldron.host.cpu;
in {
  config = mkIf (cfg == "intel" || cfg == "vm-intel") {
    hardware.cpu.intel.updateMicrocode = true;

    boot = {
      kernelModules = [ "kvm-intel" ];
      kernelParams = [
        "i915.fastboot=1"
        "enable_gvt=1"
      ];
    };
  };
} 

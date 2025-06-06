{ lib, config, ... }:
let
  inherit (lib) mkIf;
  cfg = config.cauldron.host.cpu;
in {
  config = mkIf (cfg == "amd" || cfg == "vm-amd") {
    hardware.cpu.amd.updateMicrocode = true;
    
    boot = {
      kernelModules = [
        "kvm-amd"
        "amd-pstate"
      ];
    };
  };
} 

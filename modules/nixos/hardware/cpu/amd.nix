{ lib, config, ... }:
let
  inherit (lib) mkIf;
  cfg = config.cauldron.host.hardware;
in {
  config = mkIf (cfg.cpu == "amd" || cfg.cpu == "vm-amd") {
    hardware.cpu.amd.updateMicrocode = true;
    
    boot = {
      kernelModules = [
        "kvm-amd"
        "amd-pstate"
      ];
    };
  };
}

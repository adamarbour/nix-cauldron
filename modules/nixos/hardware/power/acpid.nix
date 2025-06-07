{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf;
  profiles = config.cauldron.profiles;
in {
  config = mkIf (lib.elem "laptop" profiles) {
    environment.systemPackages = [
      pkgs.acpi
      pkgs.powertop
    ];
    
    boot = {
      kernelModules = [ "acpi_call" ];
      extraModulePackages = with config.boot.kernelPackages; [
        acpi_call
        cpupower
      ];
    };
    hardware.acpilight.enable = false;
    services.acpid.enable = true;
  };
}

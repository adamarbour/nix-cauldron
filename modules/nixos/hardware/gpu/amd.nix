{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf;
  cfg = config.cauldron.host.hardware;
in {
  config = mkIf (cfg.gpu == "amd") {
    # enable amdgpu xorg drivers
    services.xserver.videoDrivers = [ "amdgpu" ];
    
    # enable amdgpu kernel module
    boot.kernelModules = [ "amdgpu" ];
    
    # enables AMDVLK & OpenCL support
    hardware.graphics.extraPackages = [
      pkgs.rocmPackages.clr
      pkgs.rocmPackages.clr.icd
    ];
  };
}

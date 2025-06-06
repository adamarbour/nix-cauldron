{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf;
  cfg = config.cauldron.host.gpu;
in {
  config = mkIf (cfg == "amd" || cfg == "amd-nv") {
    # enable amdgpu xorg drivers
    services.xserver.videoDrivers = [ "amdgpu" ];

    # enable amdgpu kernel module
    boot = {
      kernelModules = [ "amdgpu" ];
      initrd.kernelModules = [ "amdgpu" ];
    };

    # enables AMDVLK & OpenCL support
    hardware.graphics.extraPackages = [
      pkgs.amdvlk
      pkgs.rocmPackages.clr
      pkgs.rocmPackages.clr.icd
    ];
  };
} 

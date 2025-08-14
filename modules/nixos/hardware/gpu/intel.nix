{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf;
  cfg = config.cauldron.host.hardware;
in {
  config = mkIf (cfg.gpu == "intel") {
    # i915 kernel module
    boot.initrd.kernelModules = [ "i915" ];
    # we enable modesetting since this is recomeneded for intel gpus
    services.xserver.videoDrivers = [ "modesetting" ];
    
    # OpenCL support and VAAPI
    hardware.graphics = {
      extraPackages = [
        pkgs.libva-vdpau-driver
        pkgs.intel-media-driver
        pkgs.intel-vaapi-driver
      ];

      extraPackages32 = [
        pkgs.pkgsi686Linux.libva-vdpau-driver
        pkgs.pkgsi686Linux.intel-media-driver
        pkgs.pkgsi686Linux.intel-vaapi-driver
      ];
    };
    
    environment.variables = mkIf (config.hardware.graphics.enable) {
      VDPAU_DRIVER = "va_gl";
    };
  };
}

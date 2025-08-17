{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf;
  cfg = config.cauldron.host.hardware;
in {
  config = mkIf (cfg.gpu == "intel") {
    # i915 kernel module
    boot.initrd.kernelModules = [ "i915" ];
    boot.kernelParams = [ "i915.fastboot=1" ];
    # we enable modesetting since this is recomeneded for intel gpus
    services.xserver.videoDrivers = [ "modesetting" ];
    
    # OpenCL support and VAAPI
    hardware.graphics = {
      extraPackages = with pkgs; [
        libva-vdpau-driver
        intel-media-driver
        intel-vaapi-driver
      ];

      extraPackages32 = with pkgs.pkgsi686Linux; [
        libva-vdpau-driver
        intel-media-driver
        intel-vaapi-driver
      ];
    };
    
    environment.variables = mkIf (config.hardware.graphics.enable) {
      VDPAU_DRIVER = "va_gl";
    };
  };
}

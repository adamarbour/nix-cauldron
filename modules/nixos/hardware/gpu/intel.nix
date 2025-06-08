{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf attrValues;
  cfg = config.cauldron.host.gpu;
in {
  config = mkIf (cfg == "intel" || cfg == "intel-nv") {
    # i915 kernel module
    boot.initrd.kernelModules = [ "i915" ];
    # we enable modesetting since this is recomeneded for intel gpus
    services.xserver = mkIf (cfg == "intel") {
      videoDrivers = [ "modesetting" ];
    };
    
    # OpenCL support and VAAPI
    hardware.graphics = {
      extraPackages = attrValues {
        inherit (pkgs) libva-vdpau-driver intel-media-driver;
        intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
      };

      extraPackages32 = attrValues {
        inherit (pkgs.pkgsi686Linux) libva-vdpau-driver intel-media-driver;
        intel-vaapi-driver = pkgs.pkgsi686Linux.intel-vaapi-driver.override { enableHybridCodec = true; };
      };
    };
    
    hardware.intel-gpu-tools.enable = true;

    environment.variables = mkIf (config.hardware.graphics.enable && cfg != "intel-nv") {
      VDPAU_DRIVER = "va_gl";
    };
  };
} 

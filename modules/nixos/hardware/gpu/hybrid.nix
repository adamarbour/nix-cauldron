{ lib, pkgs, config, ... }:
let
  inherit (lib) mkMerge mkIf mkDefault mkForce attrValues;
  cfg = config.cauldron.host.hardware;
in {
  config = mkMerge [
    (mkIf (cfg.gpu == "hybrid") {
      hardware.nvidia.prime = {
        sync.enable = mkForce false;
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
      };
    })
    
    (mkIf (cfg.gpu == "hybrid" && cfg.cpu == "intel") {
      boot.initrd.kernelModules = [ "i915" ];
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
    })
    
    (mkIf (cfg.gpu == "hybrid" && cfg.cpu == "amd") {
      # enable amdgpu kernel module
      boot.kernelModules = [ "amdgpu" ];
      
      # enables AMDVLK & OpenCL support
      hardware.graphics.extraPackages = [
        pkgs.rocmPackages.clr
        pkgs.rocmPackages.clr.icd
      ];
    })
  ];
}

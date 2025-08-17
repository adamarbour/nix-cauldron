{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf;
  cfg = config.cauldron.host.hardware;
in {
  config = mkIf (cfg.gpu == "nvidia" || cfg.gpu == "hybrid") {
    services.xserver.videoDrivers = [ "nvidia" ];
    
    environment.systemPackages = [
      pkgs.nvtopPackages.nvidia
      # vulkan
      pkgs.vulkan-tools
      pkgs.vulkan-loader
      pkgs.vulkan-validation-layers
      pkgs.vulkan-extension-layer
      # libva
      pkgs.libva
      pkgs.libva-utils
    ];
    
    hardware = {
      nvidia = {
        # use the latest and greatest nvidia drivers
        package = config.boot.kernelPackages.nvidiaPackages.stable;

        powerManagement = {
          enable = true;
          finegrained = false;
        };

        # dont use the open drivers by default
        open = false;

        # adds nvidia-settings to pkgs, so useless on nixos
        nvidiaSettings = false;

        nvidiaPersistenced = true;
      };
      graphics = {
        extraPackages = [ pkgs.nvidia-vaapi-driver ];
        extraPackages32 = [ pkgs.pkgsi686Linux.nvidia-vaapi-driver ];
      };
    };
    
    # Enables the Nvidia's experimental framebuffer device
    # fix for the imaginary monitor that does not exist
    boot.kernelParams = [ "nvidia_drm.fbdev=1" "nvidia_drm.modeset=1" ];
    boot.blacklistedKernelModules = [ "nouveau" ];
    
    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "nvidia";
    };
  };
}

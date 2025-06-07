{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf mkDefault;
  cfg = config.cauldron.host.gpu;
in {
  config = mkIf (cfg == "nvidia" || cfg == "intel-nv" || cfg == "amd-nv") {
    # nvidia drivers kinda are unfree software
    nixpkgs.config.allowUnfree = true;
    
    services.xserver.videoDrivers = mkDefault [ "nvidia" ];
    
    boot = {
      # blacklist nouveau module as otherwise it conflicts with nvidia drm
      blacklistedKernelModules = [ "nouveau" ];

      # Enables the Nvidia's experimental framebuffer device
      # fix for the imaginary monitor that does not exist
      kernelParams = [ "nvidia_drm.fbdev=1" ];
    };
    
    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "nvidia";
    };
    
    hardware = {
      nvidia = {
        package = mkDefault config.boot.kernelPackages.nvidiaPackages.beta;
        open = false; # dont use the open drivers by default
        nvidiaSettings = false; # adds nvidia-settings to pkgs, so useless on nixos
        nvidiaPersistenced = true;
        # forceFullCompositionPipeline = true;
        powerManagement = {
          enable = mkDefault true;
          finegrained = mkDefault false;
        };
        prime = mkIf (cfg == "intel-nv" || cfg == "amd-nv") {
          # TODO: Make these configurable
          intelBusId = "PCI:0:2:0";
          nvidiaBusId = "PCI:1:0:0";
          offload = {
            enable = if cfg == "nvidia" then false else true; # Dedicated by default. Hybrid otherwise.
            enableOffloadCmd = config.hardware.nvidia.prime.offload.enable;
          };
        };
      };
      graphics = {
        extraPackages = [ pkgs.nvidia-vaapi-driver ];
        extraPackages32 = [ pkgs.pkgsi686Linux.nvidia-vaapi-driver ];
      };
    };
  };
} 

{ config, lib, pkgs, ... }:
{  
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  
  cauldron = {
    host.cpu = "intel";
    host.gpu = "intel-nv";
    host.bluetooth.enable = true;
    host.bluetooth.onBoot = false;
    host.tpm.enable = true;
    
    host.kernel = pkgs.unstable.linuxPackages_6_14;
    host.enableKernelTweaks = true;
    host.tmpOnTmpfs = false;
    
    host.boot.extraModprobeConfig = ''
      options i915 enable_dc=2 enable_fbc=1 enable_psr=1
      options iwlwifi power_save=true
    '';
    host.boot.loader = "systemd-boot";
    host.boot.secureBoot = false; # TODO: Fixme...
    host.boot.silentBoot = true;
    host.boot.initrd.enableTweaks = true;
    
    networking.optimize = true;
    networking.wireless.backend = "iwd";
    
    impermanence.enable = true;
    secrets.enable = true;
    profiles = [
      "laptop"
      "graphical"
      "workstation"
    ];
  };
}

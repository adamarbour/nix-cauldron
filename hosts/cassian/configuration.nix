{ config, lib, pkgs, ... }:
{  
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  
  cauldron = {
    host.cpu = "intel";
    host.gpu = "intel-nv";
    host.bluetooth.enable = true;
    host.tpm.enable = true;
    
    host.kernel = pkgs.linuxPackages;
    host.enableKernelTweaks = true;
    host.tmpOnTmpfs = false;
    
    host.boot.loader = "systemd-boot";
    host.boot.silentBoot = true;
    host.boot.initrd.enableTweaks = true;
    
    profiles = [
      "laptop"
      "graphical"
      "workstation"
    ];
  };
}

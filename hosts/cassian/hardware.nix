{ config, lib, pkgs, modulesPath, inputs, ... }:

{
  boot = {
    blacklistedKernelModules = [ "nouveau" ];
    consoleLogLevel = 0;
    initrd = {
      verbose = false;
      availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ "i915" "xe" "uvcvideo" ];
      systemd.enable = true;
      systemd.strip = true;
    };
    kernelModules = [ "kvm-intel" ];
    kernelPackages = pkgs.linuxPackages_xanmod;
    kernelParams = [
      "quiet"
      "udev.log_level=3"
      "rd.systemd.show_status=auto"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "nvidia.NVreg_TemporaryFilePath=/var/tmp"
    ];
    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot/";
    };
    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot.enable = lib.mkForce false;
    loader.systemd-boot.configurationLimit = 3;
    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = 0;
    plymouth = {
      enable = true;
    };
    tmp.cleanOnBoot = true;
  };
  
  fileSystems = {
    "/persist".neededForBoot = true;
    "/var/log".neededForBoot = true;
    "/tmp".neededForBoot = true;
  };
  
  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    
    logitech.wireless.enable = true;
    
    graphics = {
      enable = true;
      extraPackages = [
        pkgs.intel-media-driver
        pkgs.intel-compute-runtime
        pkgs.vpl-gpu-rt
      ];
      extraPackages32 = [
        pkgs.driversi686Linux.intel-media-driver
      ];
    };
    
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
	      General = {
		      Experimental = true;
	      };
      };
    };
    
    nvidia = {
      open = true;
      nvidiaSettings = true;
      modesetting.enable = true;
      powerManagement = {
        enable = true;
        finegrained = true;
      };
      prime = {
        offload.enable = true;
        offload.enableOffloadCmd = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
  };
  
  services.udev.packages = with pkgs; [ solaar ];

  services.xserver.videoDrivers = [ "nvidia" ];

  services.btrfs.autoScrub.enable = lib.mkDefault true;
  services.printing = {
    enable = true;
    drivers = [ pkgs.cnijfilter2 ];
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  
  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = lib.mkDefault true;
    alsa.enable = lib.mkDefault true;
    alsa.support32Bit = lib.mkDefault true;
    pulse.enable = lib.mkDefault true;
    jack.enable = lib.mkDefault true;
  };
  
  # Bluetooth
  services.blueman.enable = true;
}

{ config, lib, pkgs, ... }:
let
  inherit (lib) mkForce;
in {
  boot = {
    kernelParams = [ "intel_pstate=disable" "intel_idle.max_cstate=1" ];
    blacklistedKernelModules = [ "i915" ];
  };
  powerManagement.cpuFreqGovernor = mkForce "powersave";
  
  # Expose clocks/volts
  services.xserver.deviceSection = ''
    Option "Coolbits" "28"
  '';
  
  environment.sessionVariables = {
    # Enable VRR and caching
    __GL_GSYNC_ALLOWED = "1";
    __GL_VRR_ALLOWED = "1";
    __GL_SHADER_DISK_CACHE = "1";
    __GL_SHADER_DISK_CACHE_PATH = "$XDG_CACHE_HOME/nv";
    
    # DLSS and NVAPI
    DXVK_ENABLE_NVAPI = "1";
    DXVK_NVAPIHACK = "0";
  };
  
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/61ba0640-2742-4d4c-a794-b3ebb4d3eeaf";
    fsType = "ext4";
    options = [ "noatime" "nodiratime" "discard" ];
  };
  
  fileSystems."/home" = {
    device = "/dev/disk/by-label/GAMES";
    fsType = "ext4";
    options = [ "noatime" "nodiratime" "discard" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/8656-893C";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [ ];
}

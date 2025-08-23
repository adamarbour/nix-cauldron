{ config, lib, pkgs, ... }:
let
  inherit (lib) mkForce;
in {
  boot = {
    kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" "intel_rapl_common" "intel_rapl_msr" "msr" ];
    kernelParams = [ "nvidia-drm.modeset=1" "nvidia-drm.fbdev=1" ];
    blacklistedKernelModules = [ "i915" ];
  };
  
  # Expose clocks/volts
  services.xserver.deviceSection = ''
    Option "Coolbits" "28"
  '';
  
  systemd.services.clear-bdprochot = {
    description = "Clear BD-PROCHOT bit in MSR 0x1FC";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash -c '" +
        "old=$(${pkgs.msr-tools}/bin/rdmsr 0x1FC) && " +
        "new=$((0x$old & 0xFFFFE)) && " +
        "${pkgs.msr-tools}/bin/wrmsr 0x1FC \"$new\" && " +
        "echo \"BD-PROCHOT cleared (old: 0x$old → new: 0x$new)\"" +
        "'";
      # Run as root
      User = "root";
      Group = "root";
    };
  };
  
  # Set GPU Fan Speed
  systemd.services."nvidia-fan-50" = {
    description = "Set NVIDIA GPU fan to 50%";
    wantedBy = [ "graphical.target" ];
    after = [ "graphical.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/current-system/sw/bin/nvidia-settings -a GPUFanControlState=1 -a GPUTargetFanSpeed=70 -c 0";
    };
  };
  
  # Set GPU Clocks
  systemd.services."nvidia-tune-pl" = {
    description = "Tune NVIDA for SFF";
    wantedBy = [ "graphical.target" ];
    after = [ "graphical.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/current-system/sw/bin/nvidia-smi -pl 70";
    };
  };
  systemd.services."nvidia-tune-lgc" = {
    description = "Tune NVIDA for SFF";
    wantedBy = [ "graphical.target" ];
    after = [ "graphical.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/current-system/sw/bin/nvidia-smi -lgc 1290,1290";
    };
  };
  systemd.services."nvidia-tune-lmc" = {
    description = "Tune NVIDA for SFF";
    wantedBy = [ "graphical.target" ];
    after = [ "graphical.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/current-system/sw/bin/nvidia-smi -lmc 6001,6001";
    };
  };
  systemd.services.intel-undervolt = {
    description = "Intel Undervolt Service";
    wantedBy = [ "multi-user.target" "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    after = [ "multi-user.target" "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    serviceConfig = {
      ExecStartPre="${pkgs.coreutils}/bin/sleep 30";
      ExecStart = ''
        ${pkgs.intel-undervolt}/bin/intel-undervolt apply
      '';
      Restart = "on-failure";
    };
  };
  
  environment.etc."intel-undervolt.conf".text = ''
    power package 35/10 35/81920
  '';
  
  environment.sessionVariables = {
    # Enable VRR and caching
    __GL_GSYNC_ALLOWED = "1";
    __GL_VRR_ALLOWED = "1";
    __GL_SHADER_DISK_CACHE = "1";
    __GL_SHADER_DISK_CACHE_PATH = "$\{XDG_CACHE_HOME\}/nv";
    
    # DLSS and NVAPI
    DXVK_ENABLE_NVAPI = "1";
    DXVK_NVAPIHACK = "0";
    
    # CAP FRAMERATE
    __GL_MaxFramesAllowed = "2";
    __GL_MaxFramesPerSecond = "90";
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

{ config, lib, pkgs, ... }:
let
  inherit (lib) mkForce;
in {
  boot = {
    kernelModules = [ "intel_rapl_common" "intel_rapl_msr" "msr" ];
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
  systemd.services."nvidia-fan-70" = {
    description = "Set NVIDIA GPU fan to 70%";
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
      ExecStart = "/run/current-system/sw/bin/nvidia-smi -pl 65";
    };
  };
  systemd.services."nvidia-tune-lgc" = {
    description = "Tune NVIDA for SFF";
    wantedBy = [ "graphical.target" ];
    after = [ "graphical.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/run/current-system/sw/bin/nvidia-smi -lgc 1305,1305";
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
  
  # Setup CPU undervolt given that this has an "unsupported" CPU
  environment.etc."intel-undervolt.conf".text = ''
    power package 45/10 45/81920
  '';
  systemd.services.intel-undervolt = {
    description = "Intel Undervolt Service";
    wantedBy = [ "multi-user.target" "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    after = [ "multi-user.target" "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    serviceConfig = {
      ExecStartPre="${pkgs.coreutils}/bin/sleep 60";
      ExecStart = ''
        ${pkgs.intel-undervolt}/bin/intel-undervolt apply
      '';
      Restart = "on-failure";
    };
  };
  
  # Sound Setup - Default to HDMI. Switch to Headset when found.
  services.pipewire.wireplumber.extraConfig = {
    "10-default-audio" = {
      "monitor.alsa.rules" = [
        { matches = [ { "device.name" = "~alsa_output.*hdmi.*" ; } ];
          actions = { "update-props" = { "device.priority" = 100; }; };
        }
        { matches = [ { "device.name" = "~alsa_output.*usb.*" ; } ];
          actions = { "update-props" = { "device.priority" = 150; }; };
        }
      ];
    };
  };
  
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
}

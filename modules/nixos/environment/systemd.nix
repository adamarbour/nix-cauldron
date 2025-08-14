{ lib, config, ... }:
let
  inherit (lib) mkIf mkDefault;
  profiles = config.cauldron.profiles;
in {
  systemd = {
    # Prefer to continue booting in all scenarios
    enableEmergencyMode = false;
    
    extraConfig = ''
      DefaultTimeoutStartSec = "30s";
      DefaultTimeoutStopSec = "30s";
      DefaultTimeoutAbortSec = "30s";
      DefaultDeviceTimeoutSec = "30s";
    '';
    
    user.extraConfig = ''
      DefaultTimeoutStartSec=15s
      DefaultTimeoutStopSec=15s
      DefaultTimeoutAbortSec=15s
      DefaultDeviceTimeoutSec=15s
    '';
    
    watchdog = {
      runtimeTime = mkDefault "15s";
      rebootTime = mkDefault "30s";
      kexecTime = mkDefault "1m";
    };
  };
}

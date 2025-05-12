{ lib, config, inputs, ... }:
let
  inherit (lib.modules) mkDefault;

  cfg = config.cauldron.environment;
in {
  config = {
    systemd = {
      enableEmergencyMode = false;
      watchdog = {
        runtimeTime = mkDefault "15s";
        rebootTime = mkDefault "30s";
        kexecTime = mkDefault "1m";
      };
    };
  };
}
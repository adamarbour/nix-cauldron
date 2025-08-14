{ lib, config, ... }:
let
  inherit (lib) mkDefault;
  profiles = config.cauldron.profiles;
in {
  config = {
    services.earlyoom = {
      enable = mkDefault (lib.elem "server" profiles); # server
      reportInterval = 0;
      freeSwapThreshold = 5;
      freeSwapKillThreshold = 2;
      freeMemThreshold = 5;
      freeMemKillThreshold = 2;
    };
  };
}

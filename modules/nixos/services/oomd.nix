{ lib, config, ... }:
let
  inherit (lib) mkDefault;
  profiles = config.cauldron.profiles;
in {
  config = {
    systemd = {
      # Systemd OOMd
      oomd = {
        enable = mkDefault (!(lib.elem "server" profiles)); # !server
        enableRootSlice = true;
        enableUserSlices = true;
        enableSystemSlice = true;
        extraConfig.DefaultMemoryPressureDurationSec = "20s";
      };
      
      services.nix-daemon.serviceConfig.OOMScoreAdjust = mkDefault 350;
    };
  };
}

{ lib, config, ... }:
let
  inherit (lib) mkIf mkDefault;
  profiles = config.cauldron.profiles;
in
{
  config = mkIf (lib.elem "laptop" profiles) {
    services.logind = {
      lidSwitch = "suspend";
      lidSwitchDocked = "ignore";
      lidSwitchExternalPower = "suspend";
      powerKey = "suspend";
      powerKeyLongPress = "poweroff";
    };
#    systemd.sleep.extraConfig = ''
#      HibernateDelaySec=1h
#    '';
  };
}

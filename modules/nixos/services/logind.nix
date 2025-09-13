{ lib, config, ... }:
let
  inherit (lib) mkIf mkMerge mkDefault;
  profiles = config.cauldron.profiles;
  
  roleCheck = [ "server" "laptop" "desktop" ];
  role = builtins.head (builtins.filter (p: builtins.elem p roleCheck) profiles);
  has = p: builtins.elem p profiles;
in {
  config = mkMerge [
    # COMMON CONFIG
    {
      services.logind = {
        powerKey = mkDefault "poweroff";
        suspendKey = mkDefault "suspend";
        hibernateKey = mkDefault "hibernate";
        extraConfig = ''
          NAutoVTs=0
          IdleAction=ignore
          InhibitDelayMaxSec=30
          HibernateDelaySec=1h
        '';
      };
      systemd.sleep.extraConfig = ''
        SuspendState=mem
        AllowSuspendThenHibernate=yes
      '';
    }
    
    # SERVER
    (mkIf (has "server") {
      services.logind = {
        powerKey = "ignore";
        powerKeyLongPress = "poweroff";
        lidSwitch = "ignore";
        lidSwitchDocked = "ignore";
        lidSwitchExternalPower = "ignore";
        killUserProcesses = true;
        extraConfig = ''
          NAutoVTs=0
          IdleAction=ignore
          IdleActionSec=0
          InhibitDelayMaxSec=10
        '';
      };
      systemd.sleep.extraConfig = ''
        AllowSuspendThenHibernate=no
      '';
    })
    
    # DESKTOP
    (mkIf (has "desktop") {
      services.logind = {
        powerKey = "suspend";
        powerKeyLongPress = "poweroff";
        lidSwitch = "ignore";
        lidSwitchDocked = "ignore";
        lidSwitchExternalPower = "ignore";
        killUserProcesses = false;
        extraConfig = ''
          NAutoVTs=6
          IdleAction=ignore
          IdleActionSec=0
          InhibitDelayMaxSec=30
          HibernateDelaySec=2h
        '';
      };
      systemd.sleep.extraConfig = ''
        AllowSuspendThenHibernate=yes
      '';
    })
    
    # LAPTOP
    (mkIf (has "laptop") {
      services.logind = {
        powerKey = "suspend";
        powerKeyLongPress = "poweroff";
        suspendKey = "suspend";
        hibernateKey = "suspend";
        lidSwitch = "suspend";
        lidSwitchDocked = "ignore";
        lidSwitchExternalPower = "suspend";
        killUserProcesses = false;
        extraConfig = ''
          NAutoVTs=6
          IdleAction=suspend
          IdleActionSec=20min
          InhibitDelayMaxSec=30
        '';
      };
      systemd.sleep.extraConfig = ''
        SuspendState=s2idle
        HibernateMode=shutdown
      '';
    })
    
  ];
}

{ lib, config, ... }:
let
  inherit (lib) mkIf mkMerge mkDefault;
  profiles = config.cauldron.profiles;
  
  roleCheck = [ "server" "laptop" "desktop" ];
  role = builtins.head (builtins.filter (p: builtins.elem p roleCheck) profiles);
  has = p: builtins.elem p profiles;
  is = p: role == p;
in {
  config = mkMerge [
    # COMMON CONFIG
    {
      services.logind = {
        powerKey = mkDefault "poweroff";
        suspendKey = mkDefault "suspend";
        hibernateKey = mkDefault "hibernate";
        extraConfig = ''
          InhibitDelayMaxSec=30
          KillUserProcesses=no
        '';
      };
      systemd.sleep.extraConfig = ''
        NAutoVTs=0
        IdleAction=ignore
        SuspendState=mem
        HibernateState=disk
        AllowSuspendThenHibernate=yes
        HibernateDelaySec=1h
      '';
    }
    
    # SERVER
    (mkIf (is "server") {
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
          KillUserProcesses=yes
        '';
      };
      systemd.sleep.extraConfig = ''
        AllowSuspendThenHibernate=no
      '';
    })
    
    # DESKTOP
    (mkIf (is "desktop") {
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
          KillUserProcesses=no
        '';
      };
      systemd.sleep.extraConfig = ''
        AllowSuspendThenHibernate=yes
        HibernateDelaySec=2h
      '';
    })
    
    # LAPTOP
    (mkIf (is "laptop") {
      services.logind = {
        powerKey = "suspend-then-hibernate";
        powerKeyLongPress = "poweroff";
        suspendKey = "suspend-then-hibernate";
        hibernateKey = "suspend-then-hibernate";
        lidSwitch = "suspend-then-hibernate";
        lidSwitchDocked = "ignore";
        lidSwitchExternalPower = "suspend-then-hibernate";
        killUserProcesses = false;
        extraConfig = ''
          NAutoVTs=6
          IdleAction=suspend-then-hibernate
          IdleActionSec=30min
          InhibitDelayMaxSec=30
          KillUserProcesses=no
        '';
      };
      systemd.sleep.extraConfig = ''
        SuspendState=mem
        HibernateState=disk
        AllowSuspendThenHibernate=yes
        HibernateDelaySec=1h
      '';
    })
    
  ];
}

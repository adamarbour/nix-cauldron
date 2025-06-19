{ lib, config, pkgs, ... }:
let
  inherit (lib) mkIf mkDefault;
  profiles = config.cauldron.profiles;
in {
  security.polkit = {
    enable = true;
    debug = mkDefault true;
    
    # the below configuration depends on security.polkit.debug being set to true
    # so we have it written only if debugging is enabled
    extraConfig = mkIf config.security.polkit.debug ''
      /* Log authorization checks. */
      polkit.addRule(function(action, subject) {
        polkit.log("user " +  subject.user + " is attempting action " + action.id + " from PID " + subject.pid);
      });
    '';
  };
  
  systemd = mkIf (lib.elem "graphical" profiles) {
    user.services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = [ "graphical-session.target" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
            Type = "simple";
            ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
        };
    };
    extraConfig = ''
        DefaultTimeoutStopSec=10s
    '';
  };
}

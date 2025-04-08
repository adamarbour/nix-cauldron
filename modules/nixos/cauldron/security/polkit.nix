{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.make.security;
in {
  config = {
    # have polkit log all actions
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
  };
}
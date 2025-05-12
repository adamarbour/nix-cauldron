{ lib, config, inputs, ... }:
let
  inherit (lib.modules) mkIf mkDefault;

  cfg = config.cauldron.security;
in {
  config = {
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
{ lib, config, inputs, ... }:
let
  cfg = config.cauldron.security.pam;
in {

  # OPTION to enable u2f

  config = {
    security.pam = {
      u2f = {
        enable = true;
        settings = {
          interactive = true;
          cue = true;
        };
      };
      loginLimits = [
        {
          domain = "@wheel";
          item = "nofile";
          type = "soft";
          value = "524288";
        }
        {
          domain = "@wheel";
          item = "nofile";
          type = "hard";
          value = "1048576";
        }
      ];
    };
  };
}
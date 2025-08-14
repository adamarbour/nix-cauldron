{ lib, config, ... }:
let
  inherit (lib) mkIf;
  profiles = config.cauldron.profiles;
in {
  config = {
    services = {
      logrotate.enable = true;
      journald = {
        storage = if (!(lib.elem "server" profiles)) then "persistent" else "volatile";
        upload.enable = false;
        extraConfig = ''
          SystemMaxUse=100M
          RuntimeMaxUse=50M
          SystemMaxFileSize=50M
        '';
      };
    };
  };
}

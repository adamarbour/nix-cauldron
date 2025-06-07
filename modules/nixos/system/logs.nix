{ lib, config, ... }:
let
  inherit (lib) mkIf;
  profiles = config.cauldron.profiles;
in {
  config = mkIf (!(lib.elem "server" profiles)) {
    # limit systemd journal size
    # https://wiki.archlinux.org/title/Systemd/Journal#Persistent_journals
    services.journald.extraConfig = ''
      SystemMaxUse=100M
      RuntimeMaxUse=50M
      SystemMaxFileSize=50M
    '';
  };
}

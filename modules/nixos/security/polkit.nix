{ lib, config, ... }:
let
  profiles = config.cauldron.profiles;
in {
  # have polkit log all actions
  security = {
    polkit.enable = true;

    # enable for graphical environments
    soteria.enable = (lib.elem "graphical" profiles);
  };
  systemd.tmpfiles.rules = [
    "d /run/polkit-1/rules.d 0755 root root -"
  ];
}

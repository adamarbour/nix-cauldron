{ lib, config, ... }:
let
  inherit (lib) mkIf;
  profiles = config.cauldron.profiles;
in {
  fonts = mkIf (lib.elem "graphical" profiles) {
    fontconfig = {
      enable = true;
      hinting.enable = true;
      antialias = true;
    };
  };
}

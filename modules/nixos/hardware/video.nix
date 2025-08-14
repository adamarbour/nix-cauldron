{ lib, pkgs, config, ...}:
let
  inherit (lib) mkIf;
  profiles = config.cauldron.profiles;
in {
  config = mkIf (lib.elem "graphical" profiles) {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}

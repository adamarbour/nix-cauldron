{ lib, config, ... }:
let
  profiles = config.cauldron.profiles;
in {
  programs = {
    command-not-found.enable = false;
    pay-respects.enable = (lib.elem "graphical" profiles);
  };
}
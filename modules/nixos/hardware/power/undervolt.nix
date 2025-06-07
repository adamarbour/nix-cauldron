{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf;
  profiles = config.cauldron.profiles;
in {
  config = mkIf (lib.elem "laptop" profiles) {
    services.thermald.enable = config.cauldron.host.cpu == "intel";
  };
}

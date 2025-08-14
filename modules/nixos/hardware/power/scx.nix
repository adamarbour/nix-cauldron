{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf;
  profiles = config.cauldron.profiles;
in {
  config = mkIf (lib.elem "gaming" profiles) {
    services = {
      system76-scheduler.settings.cfsProfiles.enable = false;
      scx = {
        enable = true;
        scheduler = "scx_rustland";
        package = pkgs.scx.rustscheds;
      };
    };
  };
}

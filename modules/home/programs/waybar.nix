{ lib, pkgs, config, osConfig, ... }:
let
  inherit (lib) mkIf mkDefault;
  inherit (lib.cauldron) hasProfile;
in {
  config = mkIf (hasProfile osConfig "graphical") {
    cauldron.packages = {
      inherit (pkgs) waybar;
    };
    
    programs.waybar = {
      enable = mkDefault false;
      package = pkgs.waybar;
      systemd.enable = true;
    };
  };
}

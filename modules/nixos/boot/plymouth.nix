{ lib, pkgs, config, sources, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  inherit (lib.cauldron) hasProfile;
in {
  
  config = mkIf (hasProfile config "graphical") {
    boot.plymouth = {
      enable = true;
      theme = "bgrt";
    };
  };
}

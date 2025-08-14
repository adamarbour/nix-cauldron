{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  profiles = config.cauldron.profiles;
in {
  
  config = mkIf (lib.elem "graphical" profiles) {
    boot.plymouth = {
      enable = true;
      theme = "nixos-bgrt";
      themePackages = [ pkgs.nixos-bgrt-plymouth ];
    };
  };
}

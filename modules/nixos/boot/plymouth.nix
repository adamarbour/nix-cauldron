{ lib, pkgs, config, sources, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  profiles = config.cauldron.profiles;
  mac-style-load = pkgs.callPackage "${sources.nix-mac-plymouth}/package.nix" {};
in {
  
  config = mkIf (lib.elem "graphical" profiles) {
    boot.plymouth = {
      enable = true;
      theme = "mac-style";
      themePackages = [ mac-style-load ];
    };
  };
}

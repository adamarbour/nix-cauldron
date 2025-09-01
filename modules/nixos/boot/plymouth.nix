{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  profiles = config.cauldron.profiles;
in {
  
  config = mkIf (lib.elem "graphical" profiles) {
    boot.plymouth = {
      enable = true;
      theme = "liquid";
      themePackages = [
        (pkgs.adi1090x-plymouth-themes.override {
          selected_themes = [ "liquid" "rog_2" ];
        })
      ];
    };
  };
}

{ lib, config, osConfig, ... }:
let
  inherit (lib) mkIf mkDefault;
  inherit (lib.cauldron) hasProfile;
in {
  xdg = {
    enable = true;
    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
    
    userDirs = mkIf (hasProfile osConfig "graphical") {
      enable = true;
      createDirectories = true;
      
      documents = "${config.home.homeDirectory}/Documents";
      download = "${config.home.homeDirectory}/Downloads";
      desktop = "${config.home.homeDirectory}/Desktop";
      videos = "${config.home.homeDirectory}/Media/Videos";
      music = "${config.home.homeDirectory}/Media/Music";
      pictures = "${config.home.homeDirectory}/Media/Pictures";
      publicShare = "${config.home.homeDirectory}/public/share";
      templates = "${config.home.homeDirectory}/public/templates";

      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/screenshots";
        XDG_DEV_DIR = "${config.home.homeDirectory}/Projects";
      };
    };
  };
}

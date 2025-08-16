{ lib, pkgs, config, ...}:
let
  inherit (lib) mkIf mkDefault;
  profiles = config.cauldron.profiles;
in {
  config = mkIf (lib.elem "server" profiles) {
    programs.git.package = mkDefault pkgs.gitMinimal;
    environment.variables.BROWSER = "echo";
    fonts.fontconfig.enable = mkDefault false;
    
    # freedesktop xdg files
    xdg.autostart.enable = mkDefault false;
    xdg.icons.enable = mkDefault false;
    xdg.menus.enable = mkDefault false;
    xdg.mime.enable = mkDefault false;
    xdg.sounds.enable = mkDefault false;
    
    # UTC everywhere!
    time.timeZone = mkDefault "UTC";
  };
}

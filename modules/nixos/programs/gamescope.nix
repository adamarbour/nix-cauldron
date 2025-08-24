{ lib, pkgs, config, ...}:
let
  inherit (lib) mkIf mkDefault;
  profiles = config.cauldron.profiles;
in {
  config = mkIf (lib.elem "gaming" profiles) {
    programs.gamescope = {
      enable = config.programs.steam.gamescopeSession.enable;
      capSysNice = true;
    };
    environment.systemPackages = with pkgs.unstable; [ gamescope ];
  };
}

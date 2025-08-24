{ lib, pkgs, config, ...}:
let
  inherit (lib) mkIf getExe concatStringsSep;
  profiles = config.cauldron.profiles;
  
  sessionData = config.services.displayManager.sessionData.desktops;
  sessionPath = concatStringsSep ":" [
    "${sessionData}/share/xsessions"
    "${sessionData}/share/wayland-sessions"
  ];
in {
  config = mkIf (lib.elem "graphical" profiles) {
    services.greetd = {
      enable = true;
      restart = true;
      
      settings = {
        default_session = {
          user = "greeter";
          command = concatStringsSep " " [
            (getExe pkgs.greetd.tuigreet)
            "--time"
            "--remember"
            "--remember-user-session"
            "--asterisks"
            "--sessions '${sessionPath}'"
          ];
        };
      };
    };
  };
}

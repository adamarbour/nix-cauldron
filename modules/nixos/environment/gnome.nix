{ lib, pkgs, config, ...}:
let
  inherit (lib) mkIf mkForce;
  profiles = config.cauldron.profiles;
in {
  config = mkIf (lib.elem "graphical" profiles) {
    services = {
      udev.packages = [ pkgs.gnome-settings-daemon ];
      gnome = {
        glib-networking.enable = true;
        gnome-keyring.enable = true;
        gnome-remote-desktop.enable = mkForce false;
      };
    };
  };
}

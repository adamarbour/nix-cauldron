{ lib, pkgs, config, ...}:
let
  inherit (lib) mkIf mkForce;
  inherit (lib.cauldron) hasProfile;
in {
  config = mkIf (hasProfile config "graphical") {
    services = {
      udev.packages = [ pkgs.gnome-settings-daemon ];
      gnome = {
        glib-networking.enable = true;
        gnome-keyring.enable = true;
        gnome-remote-desktop.enable = mkForce false;
      };
    };
    cauldron.packages = {
      inherit (pkgs) gnome-keyring libsecret;
    };
  };
}

{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf;
  inherit (lib.cauldron) hasProfile;
  hasGnome = config.services.xserver.desktopManager.gnome.enable;
in {
  # have polkit log all actions
  security = {
    polkit.enable = true;
    # enable for graphical environments
    soteria.enable = ((hasProfile config "graphical") && (!hasGnome));
  };
  systemd.tmpfiles.rules = [
    "d /run/polkit-1/rules.d 0755 root root -"
  ];
  cauldron.packages = mkIf ((hasProfile config "graphical") && (!hasGnome)) {
    inherit (pkgs) soteria libnotify;
  };
}

{ lib, config, pkgs, inputs, ... }:
let
  inherit (lib.modules) mkDefault;

  cfg = config.cauldron.environment.xdg-portal;
in {
  # TODO: Enable lxqt if lxqt is the window manager. Otherwise use GTK.
  config = {
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
      ];
      config = {
        common = {
          default = [
            "gtk"
          ];
        };
      };
    };
  };
}

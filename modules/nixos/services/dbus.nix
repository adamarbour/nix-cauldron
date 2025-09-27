{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf;
  inherit (lib.cauldron) hasProfile;
in {
  config = mkIf (hasProfile config "graphical") {
    users.groups.netdev = {};
    services.dbus = {
      enable = true;
      # Use the faster dbus-broker instead of the classic dbus-daemon
      implementation = "broker";
      packages = with pkgs; [
        dconf
        gcr
        udisks2
      ];
    };
    services.udisks2.enable = true;
    services.gvfs.enable = true;
    programs.dconf.enable = true;
    programs.seahorse.enable = true;
  };
}

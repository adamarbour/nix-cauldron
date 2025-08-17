{ lib, pkgs, config, ...}:
let
  inherit (lib) mkIf;
  profiles = config.cauldron.profiles;
in {
  config = mkIf (lib.elem "gaming" profiles) {
    hardware = {
      uinput.enable = true;
      steam-hardware.enable = true;
      xpadneo.enable = true;
    };
    services.udev.packages = [ pkgs.steam-devices-udev-rules pkgs.game-devices-udev-rules ];
  };
}

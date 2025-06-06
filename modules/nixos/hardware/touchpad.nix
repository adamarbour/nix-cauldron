{ lib, config, ... }:
let
  inherit (lib) mkIf mkDefault;
in {
  # TODO: If it is a laptop profile
  config = {
    services.libinput = {
      enable = true;
      # disable mouse acceleration
      mouse = {
        accelProfile = "flat";
        accelSpeed = "0";
        middleEmulation = false;
      };
      # touchpad settings
      touchpad = {
        naturalScrolling = true;
        tapping = true;
        clickMethod = "clickfinger";
        horizontalScrolling = false;
        disableWhileTyping = true;
      };
      # trackpad for lenovo
      hardware.trackpoint.enable = mkDefault true;
      hardware.trackpoint.emulateWheel = mkDefault config.hardware.trackpoint.enable;
    };
  };
}

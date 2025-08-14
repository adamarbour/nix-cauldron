{ lib, config, ...}:
let
  inherit (lib) mkIf mkDefault;
  profiles = config.cauldron.profiles;
in {
  config = mkIf (lib.elem "laptop" profiles) {
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
        disableWhileTyping = true;
      };
    };
    # trackpad for lenovo
    hardware.trackpoint.enable = mkDefault true;
    hardware.trackpoint.emulateWheel = mkDefault config.hardware.trackpoint.enable;
  };
}

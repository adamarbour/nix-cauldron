{ lib, pkgs, config, ...}:
let
  inherit (lib) types mkIf mkOption mkEnableOption;
  profiles = config.cauldron.profiles;
  cfg = config.cauldron.host.feature.touchscreen;
in {
  options.cauldron.host.feature.touchscreen = {
    enable = mkEnableOption "Touch screen support";
    autoRotate = mkEnableOption "Auto-rotate via iio-sensor-proxy";
    stylus = {
      enable = mkEnableOption "Stylus support";
      backend = mkOption {
        type = types.enum [ "libinput" "opentabletdriver" ];
        default = "libinput";
      };
    };
  };
  
  config = mkIf cfg.enable {
    boot.kernelModules = [
      "hid_multitouch"
    ] ++ (lib.optional cfg.stylus.enable "wacom");
    
    hardware.sensor.iio.enable = cfg.enable && cfg.autoRotate;
    hardware.opentabletdriver = {
      enable = cfg.stylus.backend == "opentabletdriver";
      daemon.enable = cfg.stylus.backend == "opentabletdriver";
    };
    
    services.libinput.enable = true;
    services.udev.packages = with pkgs; [ libwacom ];
    
    environment.systemPackages = with pkgs; [
      libwacom
    ];
  };
}

{ lib, pkgs, config, ...}:
let
  inherit (lib) types mkIf mkOption mkEnableOption;
  inherit (lib.lists) optionals;
  profiles = config.cauldron.profiles;
  cfg = config.cauldron.host.feature.touchscreen;
in {
  options.cauldron.host.feature.touchscreen = {
    enable = mkEnableOption "Touch screen support";
    sensors = mkEnableOption "Auto-rotate via iio-sensor-proxy";
    includeTools = mkEnableOption "Include troubleshooting and calibration tools";
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
    
    hardware.sensor.iio.enable = cfg.enable && cfg.sensors;
    hardware.opentabletdriver = {
      enable = cfg.stylus.backend == "opentabletdriver";
      daemon.enable = cfg.stylus.backend == "opentabletdriver";
    };
    
    services.xserver.wacom.enable = true;
    services.libinput.enable = cfg.stylus.backend == "libinput";
    services.udev.packages = with pkgs; [ libwacom ];
    
    environment.systemPackages = with pkgs; [
      libwacom
    ] ++ optionals cfg.includeTools [
      libinput evtest wev wlr-randr jq
      weston xorg.xinput xinput_calibrator
      usbutils pciutils lshw
    ];
  };
}

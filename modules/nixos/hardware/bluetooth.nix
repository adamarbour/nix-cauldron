{ lib, pkgs, config, ... }:
let
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.types) bool;
  inherit (lib.options) mkEnableOption mkOption;
  
  cfg = config.cauldron.host.bluetooth;
in {
  options.cauldron.host.bluetooth = {
    enable = mkEnableOption "Should the device load bluetooth drivers and enable blueman";
    onBoot = mkOption {
      type = bool;
      default = false;
      description = "Should the device start bluetooth service on boot";
    };
  };
  
  config = mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      package = pkgs.bluez-experimental;
      powerOnBoot = cfg.onBoot;
      disabledPlugins = [ "sap" ];
      settings = {
        General = {
          ControllerMode = "dual";
          FastConnectable = true;
          JustWorksRepairing = "always";
          MultiProfile = "multiple";
          Privacy = "device";
        };
        Policy = {
          ReconnectIntervals = "1,1,2,3,5,8,13,21,34,55";
          AutoEnable = true;
        };
        LE = {
          MinConnectionInterval = "7";
          MaxConnectionInterval = "9";
          ConnectionLatency = "0";
        };
      };
    };
    services.blueman.enable = mkDefault true;
  };
}

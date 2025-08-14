{ lib, pkgs, config, ...}:
let
  inherit (lib) types mkIf mkDefault mkOption;
  cfg = config.cauldron.host.feature;
in {
  options.cauldron.host.feature.bluetooth = mkOption {
    type = types.bool;
    default = false;
    description = "Wether to enable bluetooth support";
  };
  
  config = mkIf cfg.bluetooth {
    hardware.bluetooth = {
      enable = true;
      package = pkgs.bluez-experimental;
      disabledPlugins = [ "sap" ];
      
      settings = {
        General = {
          ControllerMode = "dual";
          FastConnectable = true;
          JustWorksRepairing = "always";
          MultiProfile = "multiple";
          Privacy = "device";
          PairableTimeout = 30;
          DiscoverableTimeout = 30;
          TemporaryTimeout = 0;
        };
        Policy = {
          ReconnectIntervals = "1,1,2,3,5,8,13,21,34,55";
          AutoEnable = true;
          Privacy = "network/on";
        };
        LE = {
          MinConnectionInterval = "7";
          MaxConnectionInterval = "9";
          ConnectionLatency = "0";
        };
      };
    };
    
    boot.kernelModules = [ "btusb" ];
    services.blueman.enable = mkDefault true;
  };
}

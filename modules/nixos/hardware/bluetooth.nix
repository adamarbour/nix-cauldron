{ lib, pkgs, config, ... }:
let
  inherit (lib.modules) mkIf mkDefault;
  inherit (lib.options) mkEnableOption;
  
  cfg = config.cauldron.host.bluetooth;
in {
  options.cauldron.host.bluetooth = {
    enable = mkEnableOption "Should the device load bluetooth drivers and enable blueman";
  };
  
  config = mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      package = pkgs.bluez;
      powerOnBoot = mkDefault true;
      disabledPlugins = [ "sap" ];
      settings = {
        General = {
          JustWorksRepairing = "always";
          FastConnectable = true;
          MultiProfile = "multiple";
          Experimental = true;
        };
      };
    };
    services.blueman.enable = mkDefault true;
  };
}

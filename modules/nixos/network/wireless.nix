{ lib, config, ... }:
let
  inherit (lib.options) mkOption;
  inherit (lib.types) enum;
  
  cfg = config.cauldron.network.wireless;
in {
  options.cauldron.network.wireless = {
    backend = mkOption {
      type = enum [
        "iwd"
        "wpa_supplicant"
      ];
      default = "wpa_supplicant";
      description = ''
        Backend that will be used for wireless connections using either `networking.wireless`
        or `networking.networkmanager.wifi.backend`
        Defaults to wpa_supplicant until iwd is stable.
      '';
    };
  };
  
  config = {
    # enable wireless database, it helps keeping wifi speedy
    hardware.wirelessRegulatoryDatabase = true;
    
    networking.wireless = {
      # WPA_SUPPLICANT
      enable = cfg.backend == "wpa_supplicant";
      userControlled.enable = true;
      allowAuxiliaryImperativeNetworks = true;

      extraConfig = ''
        update_config=1
      '';
      
      # IWD
      iwd = {
        enable = cfg.backend == "iwd";
        settings = {
          Settings.AutoConnect = true;
          General = {
            EnableNetworkConfiguration = true;
            RoamRetryInterval = 15;
          };
          Network = {
            EnableIPv6 = true;
            RoutePriorityOffset = 300;
          };
        };
      };
    };
  };
}

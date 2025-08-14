{ lib, config, ... }:
let
  inherit (lib) mkOption types;
  cfg = config.cauldron.host.network.wireless;
in {
  options.cauldron.host.network.wireless = {
    backend = mkOption {
      type = types.enum [
        "iwd"
        "wpa_supplicant"
        "none"
      ];
      default = "none";
      description = ''
        Backend that will be used for wireless connections using either `networking.wireless`
        or `networking.networkmanager.wifi.backend`
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

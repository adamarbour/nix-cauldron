{ lib, config, inputs, ... }:
let
  inherit (lib.options) mkOption;
  inherit (lib.types) enum;

  cfg = config.cauldron.networking.wireless;
in {
  
  options.cauldron.networking.wireless = {
    backend = mkOption {
      type = enum [ "iwd" "wpa" ];
      default = "wpa";
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
      # wpa_supplicant
      enable = cfg.backend == "wpa";
      userControlled.enable = true;
      allowAuxiliaryImperativeNetworks = true;
      extraConfig = ''
        update_config=1
      '';
      # iwd
      iwd = {
        enable = cfg.backend == "iwd";
        settings = {
          Settings.AutoConnect = true;
          General = {
            # AddressRandomization = "network";
            # AddressRandomizationRange = "full";
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
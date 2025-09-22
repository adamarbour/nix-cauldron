{ lib, config, ... }:
let
  inherit (lib) mkIf mkOption types;
  inherit (lib.lists) optionals;
  impermanence = config.cauldron.host.disk.impermanence;
  
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
    
    # Add impermanent directories conditionally...
    cauldron.host.impermanence.extra.dirs = [
    ] ++ optionals (impermanence.enable && cfg.backend == "iwd") [
      "/var/lib/iwd"
    ] ++ optionals (impermanence.enable && cfg.backend == "wpa_supplicant") [
      "/etc/wpa_supplicant" # Can be removed if wifi configurations become declarative...
      "/var/lib/wpa_supplicant"
    ];
    cauldron.host.impermanence.extra.files = [
    ] ++ optionals (impermanence.enable && cfg.backend == "wpa_supplicant") [
      "/etc/wpa_supplicant.conf"
    ] ++ optionals (impermanence.enable && cfg.backend == "iwd") [
      "/etc/iwd/main.conf"
    ];
    
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

{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.make.host.networking;
in {

  options.make.host.networking = {
  };

  options.make.host.networking.wifi = {
    backend = mkOption {
      type = types.enum [ "wpa_supplicant" "iwd" ];
      default = "iwd";
      description = "Which wifi backend to use";
      example = ''
        "wpa_supplicant"
      '';
    };
  };

  config = {
    networking.networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      unmanaged = [
        "interface-name:tailscale*"
        "interface-name:br-*"
        "interface-name:incusbr*"
        "interface-name:rndis*"
        "interface-name:docker*"
        "interface-name:virbr*"
        "interface-name:vboxnet*"
        "interface-name:waydroid*"
        "type:bridge"
      ];
      # WIFI
      wifi = {
        backend = cfg.wifi.backend;
        scanRandMacAddress = true;
      };
    };
  };
}
{ lib, pkgs, config, ... }:
let
  inherit (lib) optionals mkIf;
  profiles = config.cauldron.profiles;
  cfg = config.cauldron.host.network;
in {
  environment.systemPackages = optionals (lib.elem "graphical" profiles) [ pkgs.networkmanagerapplet ];
  
  networking.networkmanager = mkIf (!(lib.elem "server" profiles)) {
    enable = true;
    plugins = optionals (lib.elem "workstation" profiles) [ pkgs.networkmanager-openvpn pkgs.networkmanager-openconnect ];
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
    
    wifi = mkIf (cfg.wireless.backend != "none") {
      backend = cfg.wireless.backend;
      powersave = true;
      # MAC address randomization of a Wi-Fi device during scanning
      scanRandMacAddress = true;
    };
  };
}

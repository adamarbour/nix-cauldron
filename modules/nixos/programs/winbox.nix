{ lib, pkgs, config, ...}:
let
  inherit (lib) types mkIf mkOption;
  cfg = config.cauldron.host.feature;
in {
  options.cauldron.host.feature.winbox = mkOption {
    type = types.bool;
    default = false;
    description = "Install MikroTik Winbox via flatpak and open ports.";
  };
  
  config = mkIf cfg.winbox {
    services.flatpak.packages = [
      "com.mikrotik.WinBox"
    ];
    # Open discovery ports... 5678/udp MNDP & 2000/udp Cisco Discovery
    networking.firewall.allowedUDPPorts = [ 5678 2000 ];
  };
}

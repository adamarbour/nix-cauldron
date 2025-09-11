{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  inherit (config.services) tailscale;
  profiles = config.cauldron.profiles;
  
  cfg = config.cauldron.host.network.tailscale;
in {
  options.cauldron.host.network.tailscale = {
    enable = mkEnableOption "Tailscale VPN";
  };
  
  config = mkIf cfg.enable {
    networking.firewall = {
      trustedInterfaces = [ "${tailscale.interfaceName}" ];
    };
    
    services.tailscale = {
      enable = true;
      package = pkgs.unstable.tailscale;
      openFirewall = true;
      permitCertUid = "root";
      extraDaemonFlags = [ "--no-logs-no-support" ];
      extraUpFlags = [ "--ssh" ];
      useRoutingFeatures =  if (lib.elem "server" profiles) then "server" else "client";
    };
  };
}

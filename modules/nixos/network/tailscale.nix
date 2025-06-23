{ lib, config, ... }:
let
  inherit (lib) mkIf mkOption mkEnableOption;
  inherit (lib.types) bool listOf str;
  inherit (config.services) tailscale;
  persistRoot = if config.cauldron.impermanence.enable then "/persist/system" else "";
  
  cfg = config.cauldron.network.tailscale;
in {
  options.cauldron.network.tailscale = {
    enable = mkEnableOption "Tailscale VPN";
    
    isServer = mkOption {
      type = bool;
      default = false;
      example = true;
      description = ''
        Whether the target host should utilize Tailscale server features.
      '';
    };
    
    extraFlags = mkOption {
      type = listOf str;
      default = [ "--ssh" ];
      description = ''
        A list of command-line flags that will be passed to the Tailscale daemon on startup
        using the {option}`config.services.tailscale.extraUpFlags`.
        If `isServer` is set to true, the server-specific values will be appended to the list
        defined in this option.
      '';
    };
  };
  
  config = mkIf cfg.enable {
    networking.firewall = {
      trustedInterfaces = [ "${tailscale.interfaceName}" ];
    };
    
    services.tailscale = {
      enable = true;
      openFirewall = true;
      permitCertUid = "root";
      authKeyFile = "${persistRoot}/var/lib/tailscale.key";
      extraDaemonFlags = [ "--no-logs-no-support" ];
      extraUpFlags = cfg.extraFlags;
      useRoutingFeatures =  if (cfg.isServer) then "server" else "client";
    };
  };
}

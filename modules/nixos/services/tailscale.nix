{ lib, pkgs, config, ... }:
let
  inherit (lib) types mkIf mkDefault mkEnableOption mkOption;
  inherit (config.services) tailscale;
  inherit (lib.cauldron) hasProfile;
  cfg = config.cauldron.services.tailscale;
in {
  options.cauldron.services.tailscale = with types; {
    enable = mkEnableOption "EnableTailscale client daemon";
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
    environment.systemPackages = [
      pkgs.tailscale
    ];
    
    networking.firewall = {
      trustedInterfaces = [ "${tailscale.interfaceName}" ];
      checkReversePath = "loose";
      allowedUDPPorts = [ tailscale.port ];
    };
    
    services.tailscale = {
      enable = true;
      permitCertUid = "root";
      useRoutingFeatures = if (hasProfile config "server") then "server" else "client";
      extraDaemonFlags = [ "--no-logs-no-support" ];
      extraSetFlags = [ "--accept-dns" "--operator=${config.cauldron.system.mainUser}" ] ++ cfg.extraFlags;
    };
  };
}

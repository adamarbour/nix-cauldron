{ lib, config, inputs, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) enum;
  inherit (config.services) tailscale;

  cfg = config.cauldron.services.tailscale;
in {
  
  options.cauldron.services.tailscale = {
    enable =  mkEnableOption "Tailscale VPN";

    type = mkOption {
      type = enum [ "client" "server" "both" ];
      default = "client";
      description = ''
        Enables settings required for Tailscale’s routing features like subnet routers and exit nodes.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      authKeyFile = "/persist/tailscale.key";
      openFirewall = true;
      permitCertUid = "root";
      useRoutingFeatures = "client";
      extraUpFlags = [
        "--ssh"
      ];
      extraSetFlags = [
#        "--advertise-exit-node"
      ];
      extraDaemonFlags = [
        "--no-logs-no-support"
      ];
    };

    networking.firewall = {
      trustedInterfaces = [ "${tailscale.interfaceName}" ];
      checkReversePath = "loose";
      allowedUDPPorts = [ tailscale.port ];
    };
  };
}
{ lib, config, inputs, ... }:
let
  inherit (lib.modules) mkForce mkDefault;

  cfg = config.cauldron.networking.firewall;
in {
  
  config = {
    networking.nftables.enable = mkForce true;
    networking.firewall = {
      enable = true;

      allowPing = mkDefault true;
      pingLimit = "1/minute burst 5 packets";

      # make a much smaller and easier to read log
      logReversePathDrops = true;
      logRefusedConnections = false;

      # Don't filter DHCP packets, according to nixops-libvirtd
      checkReversePath = mkForce false;
    };
  };
}
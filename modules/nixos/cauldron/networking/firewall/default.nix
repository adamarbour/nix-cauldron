{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.make.host.networking.firewall;
in {
  imports = [
  ];

  options.make.host.networking.firewall = {
    enable = mkOption {
      type = types.bool;
      description = "Whether to enable the firewall.";
      default = true;
    };
  };

  config = {
    networking.nftables.enable = cfg.enable;
    networking.firewall = {
      enable = cfg.enable;
      # Allow PMTU / DHCP
      allowPing = true;
      pingLimit = "1/minute burst 5 packets";
      # Keep dmesg/journalctl -k output readable by NOT logging
      # each refused connection on the open internet.
      logReversePathDrops = mkDefault true;
      logRefusedConnections = mkDefault false;
      # Don't filter DHCP packets, according to nixops-libvirtd
      checkReversePath = mkForce false;
    };
  };
}
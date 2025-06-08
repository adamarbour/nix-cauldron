{ lib, pkgs, config, ... }:
let
  inherit (lib) mkEnableOption mkDefault mkForce;
  profiles = config.cauldron.profiles;
  cfg = config.cauldron.networking.firewall;
in {
  options.cauldron.networking.firewall = {
    enable = mkEnableOption true;
  };
  
  config = {
    networking.nftables.enable = cfg.enable;
    networking.firewall = {
      enable = cfg.enable;
      allowPing = if (lib.elem "server" profiles) then true else false;
      pingLimit = "1/minute burst 5 packets";
      # make a much smaller and easier to read log
      logReversePathDrops = mkDefault true;
      logRefusedConnections = mkDefault false;

      # Don't filter DHCP packets, according to nixops-libvirtd
      checkReversePath = mkForce false;
    };
  };
}

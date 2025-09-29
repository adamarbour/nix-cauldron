{ lib, pkgs, config, ... }:
let
  inherit (lib) mkForce mkDefault;
  profiles = config.cauldron.profiles;
in {
  networking.nftables = {
    enable = mkDefault true;
  };
  networking.firewall = {
    enable = true;
    
    allowedTCPPorts = [ ];
    allowedUDPPorts = [ ];
    
    allowedTCPPortRanges = [ ];
    allowedUDPPortRanges = [ ];
    
    allowPing = if (lib.elem "server" profiles) then true else false;
    pingLimit = "1/minute burst 5 packets";
    
    logReversePathDrops = true;
    logRefusedConnections = false;
    
    checkReversePath = mkDefault false;
  };
}

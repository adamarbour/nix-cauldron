{ lib, config, ... }:
let
  inherit (lib) mkDefault mkForce;
in {
  networking = {
    usePredictableInterfaceNames = mkDefault true;
    
    # Use install ISO hostid for zfs
    hostId = if (config.boot.zfs.enabled) then "8425e349" else builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName);
    
    # global dhcp has been deprecated upstream, so we use networkd instead
    # however individual interfaces are still managed through dhcp in hardware configurations
    useDHCP = mkForce false;
    useNetworkd = mkForce true;
    
    # dns
    nameservers = [
      "9.9.9.9"
      "1.1.1.1"
    ];
    
    enableIPv6 = true;
  };
}

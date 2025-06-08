{ lib, config, ... }:
let
  inherit (lib) mkOverride mkDefault mkForce;
in {
  networking = {
    # Delegate the hostname setting to dhcp/cloud-init by default
    hostName = mkOverride 1337 ""; # lower prio than lib.mkDefault
    
    # Use the same default hostID as the NixOS install ISO and nixos-anywhere.
    # This allows us to import zfs pool without using a force import.
    # ZFS has this as a safety mechanism for networked block storage (ISCSI), but
    # in practice we found it causes more breakages like unbootable machines,
    # while people using ZFS on ISCSI is quite rare.
    hostId = if (config.boot.zfs.enabled) then "8425e349" else builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName);
  
    # global dhcp has been deprecated upstream, so we use networkd instead
    # however individual interfaces are still managed through dhcp in hardware configurations
    useDHCP = mkForce false;
    useNetworkd = mkForce true;
    
    # interfaces are assigned names that contain topology information (e.g. wlp3s0) and thus should be
    # consistent across reboots this already defaults to true, we set it in case it changes upstream
    usePredictableInterfaceNames = mkDefault true;
    
    # dns
    nameservers = [
      "9.9.9.9"
      "1.1.1.1"
    ];
    
    enableIPv6 = true;
  };
}

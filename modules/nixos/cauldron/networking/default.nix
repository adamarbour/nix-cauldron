{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.make.host.networking;
in {
  imports = [
    ./firewall
  ] ++ (with builtins; map (fn: ./${fn}) (filter (fn: fn != "default.nix") (attrNames (readDir ./.))));

  options.make.host.networking = {
    
  };

  config = {
    # systemd DNS resolver daemon
    services.resolved.enable = true;

    # global dhcp has been deprecated upstream, so we use networkd instead
    # however individual interfaces are still managed through dhcp in hardware configurations
    networking.useDHCP = mkForce false;
    networking.useNetworkd = mkForce true;

    # interfaces are assigned names that contain topology information (e.g. wlp3s0) and thus should be consistent across reboots
    # this already defaults to true, we set it in case it changes upstream
    networking.usePredictableInterfaceNames = mkDefault true;

    # Use the same default hostID as the NixOS install ISO and nixos-anywhere.
    # This allows us to import zfs pool without using a force import.
    # ZFS has this as a safety mechanism for networked block storage (ISCSI), but
    # in practice we found it causes more breakages like unbootable machines,
    # while people using ZFS on ISCSI is quite rare.
    networking.hostId = mkDefault "8425e349";

    # The notion of "online" is a broken concept
    # https://github.com/systemd/systemd/blob/e1b45a756f71deac8c1aa9a008bd0dab47f64777/NEWS#L13
    systemd.services.NetworkManager-wait-online.enable = false;
    systemd.network.wait-online.enable = false;

    # Do not take down the network for too long when upgrading,
    # This also prevents failures of services that are restarted instead of stopped.
    # It will use `systemctl restart` rather than stopping it with `systemctl stop`
    # followed by a delayed `systemctl start`.
    systemd.services.systemd-networkd.stopIfChanged = false;
    # Services that are only restarted might be not able to resolve when resolved is stopped before
    systemd.services.systemd-resolved.stopIfChanged = false;
  };
}
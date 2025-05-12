{ lib, config, inputs, ... }:
let
  inherit (lib.modules) mkDefault mkForce;

  cfg = config.cauldron.networking;
in {
  imports = [
    ./firewall
  ] ++ (with builtins; map (fn: ./${fn}) (filter (fn: fn != "default.nix") (attrNames (readDir ./.))));

  config = {
    networking = {
      enableIPv6 = true;

      # Use the same default hostID as the NixOS install ISO and nixos-anywhere.
      hostId = lib.mkDefault "8425e349";
      # Delegate the hostname setting to dhcp/cloud-init by default
      hostName = lib.mkOverride 1337 ""; # lower prio than lib.mkDefault

      useDHCP = mkForce false;
      useNetworkd = mkForce true;
      usePredictableInterfaceNames = mkDefault true;
    };
  };
}
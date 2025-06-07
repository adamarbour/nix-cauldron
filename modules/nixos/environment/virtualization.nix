{ lib, config, ... }:
let
  inherit (lib) mkDefault;
in
{
  # Make sure the serial console is visible in qemu when testing the server configuration
  # with nixos-rebuild build-vm
  virtualisation.vmVariant.virtualisation.graphics = mkDefault false;
}

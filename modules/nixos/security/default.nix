{ lib, config, inputs, ... }:
let
  cfg = config.cauldron.security;
in {
  imports = [
    ./pam.nix
    ./polkit.nix
    ./sudo.nix
    ./users.nix
    ./virtualization.nix
    ./yubikey.nix
  ];
}
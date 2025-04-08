{ lib, inputs, flake, config, ... }:
{
  imports = [
    # INPUTS
    inputs.sops-nix.darwinModules.sops
    # OPTIONS
    flake.nixosModules.cauldron
  ];
  
}
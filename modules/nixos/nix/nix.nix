{ lib, config, inputs, ... }:
let
  inherit (lib.attrsets) filterAttrs attrValues mapAttrs;
  inherit (lib.modules) mkForce;
  inherit (lib.types) isType;

  flakeInputs = filterAttrs (name: value: (isType "flake" value) && (name != "self")) inputs;
in {
  config = {
    nix = {
      registry = (mapAttrs (_: flake: { inherit flake; }) flakeInputs) // {
        # https://github.com/NixOS/nixpkgs/pull/388090
        nixpkgs = mkForce { flake = inputs.nixpkgs; };
      };
      # disable usage of nix channels
      channel.enable = false;
    };
  };
}
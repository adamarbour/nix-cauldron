{ lib, config, inputs, ... }:
let

  cfg = config.cauldron.fs;
in {
  imports = [
    ./clean-root.nix
  ];
}
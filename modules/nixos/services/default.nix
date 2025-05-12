{ lib, config, inputs, ... }:
let
  cfg = config.cauldron.services;
in {
  imports = [
  ] ++ (with builtins; map (fn: ./${fn}) (filter (fn: fn != "default.nix") (attrNames (readDir ./.))));
}
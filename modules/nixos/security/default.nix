{ lib, config, inputs, ... }:
let
  cfg = config.cauldron.security;
in {
  imports = [
  ] ++ (with builtins; map (fn: ./${fn}) (filter (fn: fn != "default.nix") (attrNames (readDir ./.))));
}
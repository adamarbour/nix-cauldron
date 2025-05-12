{ lib, config, inputs, ... }:
let

  cfg = config.cauldron.programs;
in {
  imports = [
  ] ++ (with builtins; map (fn: ./${fn}) (filter (fn: fn != "default.nix") (attrNames (readDir ./.))));
}
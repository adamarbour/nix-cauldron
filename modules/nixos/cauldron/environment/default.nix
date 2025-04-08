{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.make.environment;
in {
  imports = [
  ] ++ (with builtins; map (fn: ./${fn}) (filter (fn: fn != "default.nix") (attrNames (readDir ./.))));

  options.make.environment = {
    
  };

  config = {
    
  };
}
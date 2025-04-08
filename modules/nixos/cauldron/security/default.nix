{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.make.security;
in {
  imports = [
  ] ++ (with builtins; map (fn: ./${fn}) (filter (fn: fn != "default.nix") (attrNames (readDir ./.))));

  options.make.security = {
    
  };

  config = {
    
  };
}
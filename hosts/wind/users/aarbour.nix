{ flake, pkgs, ... }:
{
  imports = [];

  home.packages = [ pkgs.hello ];
}
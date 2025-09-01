{ lib, pkgs, sources, ... }:
{
  imports = [
    (import ../../misc/fht-compositor-hm-module.nix { inherit lib pkgs sources; })
  ];
}

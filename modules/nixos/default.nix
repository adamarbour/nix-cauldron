{ lib, sources, ... }:
{
  imports = [
    ./boot
    ./hardware
    ./nix
    ./system
  ];
}

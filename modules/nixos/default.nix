{ lib, sources, ... }:
{
  imports = [
    ./boot
    ./environment
    ./hardware
    ./nix
    ./system
    ./users
  ];
}

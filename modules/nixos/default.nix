{ lib, sources, ... }:
{
  imports = [
    ./boot
    ./environment
    ./hardware
    ./nix
    ./network
    ./system
    ./users
  ];
}

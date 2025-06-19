{ lib, sources, ... }:
{
  imports = [
    ./boot
    ./environment
    ./hardware
    ./nix
    ./network
    ./security
    ./system
    ./users
  ];
}

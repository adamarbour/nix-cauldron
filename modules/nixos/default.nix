{ lib, sources, ... }:
{
  imports = [
    ./boot
    ./environment
    ./hardware
    ./nix
    ./network
    ./security
    ./services
    ./system
    ./users
  ];
}

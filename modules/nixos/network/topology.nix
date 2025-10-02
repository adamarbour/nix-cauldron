{ lib, sources, ... }:
let
  inherit (lib.topology) mkInternet;
in {
  imports = [ "${sources.nix-topology}/nixos/module.nix" ];
  
  topology = {
  
    networks.nebula = {
      name = "Nebula Cloud";
      cidrv4 = "10.24.13.0/24";
    };
  };
}

{ system ? builtins.currentSystem }:
let
  sources = import ./npins;
in {
  meta = {
    description = "Where all things were Made...";
    nixpkgs = import sources.nixpkgs {};
    specialArgs = { inherit sources; };
  };
  defaults = { lib, name, ... }: {
    imports = [
      ./modules/disks
      ./modules/nixos
      ./modules/home
      ./users/root.nix
      ./users/aarbour.nix
    ];
    config = {
      networking.hostName = name;
      deployment.targetUser = lib.mkDefault null;
    };
  };
  
  cassian = {
    imports = [
      ./hosts/cassian/configuration.nix
      ./hosts/cassian/hardware.nix
    ];
    config = {
      time.timeZone = "America/Chicago";
      deployment = {
        allowLocalDeployment = true;
        targetHost = null;
      };
    };
  };
  
  ### NFLIX - Hosts and containers supporting nflix.lol
  dlrr = {
    imports = [
      ./hosts/nflix/dlrr/configuration.nix
    ];
    config = {
      time.timeZone = "America/Chicago";
      deployment = {
        tags = [ "nflix" ];
        targetHost = "23.95.134.145";
        targetUser = "root";
      };
    };
  };
}

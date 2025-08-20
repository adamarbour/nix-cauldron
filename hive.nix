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
  
  lucien = {
    imports = [
      ./hosts/lucien/configuration.nix
      ./hosts/lucien/hardware.nix
      ./users/steam.nix
    ];
    config = {
      time.timeZone = "America/Chicago";
      deployment = {
        tags = [ "gaming" "all" ];
        targetHost = "100.110.59.111";
        targetUser = "aarbour";
      };
    };
  };
  
  ### PRYNTHIAN - Hosts and containers to support my homelab
  spring = {
    imports = [
      ./hosts/prynthian/spring/configuration.nix
      ./hosts/prynthian/spring/network.nix
    ];
    config = {
      deployment = {
        tags = [ "prynthian" ];
        targetHost = null;
        targetUser = null;
      };
    };
  };
  
  night = {
    imports = [
      ./hosts/prynthian/night/configuration.nix
      ./hosts/prynthian/night/disk.nix
      ./hosts/prynthian/night/network.nix
    ];
    config = {
      deployment = {
        tags = [ "prynthian" ];
        targetHost = null;
        targetUser = null;
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
        targetHost = "100.124.55.116";
        targetUser = "root";
      };
    };
  };
}

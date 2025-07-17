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
      (sources.disko + "/module.nix")
      ./modules/nixos
      "${sources.home-manager}/nixos" (
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit sources;
        };
      }
    )
    ];
    config = {
      networking.hostName = name;
      deployment = {
        targetUser = lib.mkDefault null;
        sshOptions = [
          "-o ConnectionTimeout=30"
          "-o ServerAliveInterval=30"
          "-o ServerAliveCountMax=30"
        ];
      };
    };
  };
  
  cassian = {
    imports = [
#      ((import sources.stylix).nixosModules.stylix) # TODO: Move me.. module me..
#      (sources.nix-flatpak + "/modules/nixos.nix") # TODO: Move me... module me..
      ./hosts/cassian/configuration.nix
      ./hosts/cassian/hardware-configuration.nix
      (import ./disks/impr-btrfs.nix {
        device = "/dev/nvme0n1";
        rootSizeMB = "1024";
        swapSizeMB = "2048";
      })
    ];
    deployment = {
      allowLocalDeployment = true;
      targetHost = null;
    };
  };
  
  nflix-dlrr = {
    imports = [
      ./hosts/nflix/dlrr/configuration.nix
      ./hosts/nflix/dlrr/disk-configuration.nix
    ];
  };
}

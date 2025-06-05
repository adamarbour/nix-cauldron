let
  sources = import ./npins;
in {
  meta = {
    description = "Where all things were Made...";
    nixpkgs = import sources.nixpkgs;
    specialArgs = { inherit sources; };
  };
  defaults = { lib, name, ... }: {
    imports = [
      (sources.disko + "/module.nix")
      (sources.impermanence + "/nixos.nix")
      (sources.sops-nix + "/modules/sops")
      ./modules/nixos
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
      ((import sources.lanzaboote).nixosModules.lanzaboote)
      ((import sources.stylix).nixosModules.stylix)
      (sources.nix-flatpak + "/modules/nixos.nix")
      ./hosts/cassian/configuration.nix
      ./hosts/cassian/hardware-configuration.nix
      (import ./disks/impr-btrfs.nix { device = "/dev/nvme0n1"; })
    ];
    deployment = {
      allowLocalDeployment = true;
      targetHost = null;
    };
  };
}

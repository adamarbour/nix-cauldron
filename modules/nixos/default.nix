{ lib, config, pkgs, inputs, ... }:
let
  cfg = config.cauldron;
in {
  imports = with inputs; [
  ### ======= MODULES ======= ###
    disko.nixosModules.disko
    impermanence.nixosModules.impermanence
    lanzaboote.nixosModules.lanzaboote
    nix-flatpak.nixosModules.nix-flatpak
    sops-nix.nixosModules.sops
    stylix.nixosModules.stylix
    home-manager.nixosModules.home-manager {
      home-manager.useUserPackages = true;
      home-manager.useGlobalPkgs = true;
      home-manager.extraSpecialArgs = { inherit inputs; };
      home-manager.users = {
        "aarbour" = import ../home;
      };
    }
  ### ======= LOCAL ======= ###
    ./environment
    ./fs
    ./networking
    ./nix
    ./programs
    ./secrets
    ./security
    ./services
  ];

  config = {
    environment.systemPackages = with pkgs; [
      home-manager
      just
    ];
  };
}

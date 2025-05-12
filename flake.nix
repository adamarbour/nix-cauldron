{
  description = "Where all things were Made...";

  outputs = inputs: with (import ./lib inputs); {
   
    ### ======= NIXOS CONFIGURATIONS ======= ###
    nixosConfigurations = {
      cassian = mkSystem ./hosts/cassian;
    };

    ### ======= HOME MANAGER CONFIGURATIONS ======= ###
    homeConfigurations = {
      #"aarbour@rhys" = mkHome "x86_64-linux" ./users/aarbour.nix;
    };
    
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # DISKO
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    # HARDWARE
    hardware.url = "github:nixos/nixos-hardware";
    # HOME-MANAGER
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # IMPERMANENCE
    impermanence.url = "github:nix-community/impermanence";
    # LANZABOOTE
    lanzaboote.url = "github:nix-community/lanzaboote/v0.4.2";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    # NIX-FLATPAK
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
    # SOPS-NIX
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    # STYLIX
    stylix.url = "github:danth/stylix/release-24.11";
    # SYSTEMS
    systems.url = "github:nix-systems/default";

    # MY
    my-keys = {
      url = "https://github.com/adamarbour.keys";
      flake = false;
    };
    my-secrets = {
      url = "git+ssh://git@github.com/adamarbour/nix-secrets?shallow=1&ref=main";
      flake = false;
    };
  };
}

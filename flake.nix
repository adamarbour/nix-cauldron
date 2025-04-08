{
  description = "Where all things were Made...";

  outputs = inputs: inputs.blueprint {
    inherit inputs;
    systems = inputs.systems;
    nixpkgs.overlays = [
      inputs.nix-topology.overlays.default
    ];
  };

  inputs = {
    # NIXPKGS
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-unstable";
    # SYSTEMS
    systems.url = "github:nix-systems/default";
    # BLUEPRINT
    blueprint.url = "github:numtide/blueprint";
    blueprint.inputs.nixpkgs.follows = "nixpkgs";
    blueprint.inputs.systems.follows = "systems";
    # COMIN
    comin.url = "github:nlewo/comin";
    comin.inputs.nixpkgs.follows = "nixpkgs";
    # DEPLOY-RS
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
    # DISKO
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    # HOME-MANAGER
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # NIX-GENERATORS
    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";
    # NIX-FACTER-MODULES
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    # NIX-TOPOLOGY
    nix-topology.url = "github:oddlama/nix-topology";
    nix-topology.inputs.nixpkgs.follows = "nixpkgs";
    # NIXOS-ANYWHERE
    nixos-anywhere.url = "github:nix-community/nixos-anywhere";
    nixos-anywhere.inputs.nixpkgs.follows = "nixpkgs";
    # SOPS-NIX
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # MY SECRETS
    my-secrets = {
      url = "git+ssh://git@github.com/adamarbour/nix-secrets?shallow=1&ref=main";
      flake = false;
    };
    # MY AUTH KEYS
    my-keys = {
      url = "https://github.com/adamarbour.keys";
      flake = false;
    };
  };
}

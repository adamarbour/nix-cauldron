inputs: let
  myLib = (import ./default.nix) { inherit inputs; };
  outputs = inputs.self.outputs;
  nixpkgs = inputs.nixpkgs;
in rec {
  pkgsFor = system: import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  mkSystem = config:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs outputs myLib; };
      modules = [
        config
        (import ../modules/nixos)
      ];
    };

  mkHome = sys: config:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsFor sys;
      extraSpecialArgs = { inherit inputs outputs myLib; };
      modules = [
        config
        (import ../modules/home)
      ];
    };

  ### ======= HELPERS
  eachSystem = nixpkgs.lib.genAttrs (import inputs.systems);
}

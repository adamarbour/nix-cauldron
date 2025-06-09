{ lib, sources, ... }:
{
  nixpkgs = {
    flake.source = sources.nixpkgs;
    overlays = [
      (self: super: { nix-direnv = self.callPackage sources.nix-direnv { }; })
      (final: _prev: {
        unstable = import sources.nixpkgs-unstable {
          config.allowUnfree = true;
        };
      })
    ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
      allowBroken = false;
      permittedInsecurePackages = [ ];
      allowUnsupportedSystem = false;
      allowAliases = false;
    };
  };
}

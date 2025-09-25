{ lib, sources, ... }:
let
  inherit (lib) mkDefault;
in {
  nixpkgs = {
    flake.source = sources.nixpkgs;
    hostPlatform = mkDefault "x86_64-linux";
    overlays = [
      (final: _prev: {
        unstable = import sources.nixpkgs-unstable {
          config.allowUnfree = true;
        };
      })
      (import ../../../overlays/mangowc.nix)
      (import ../../../overlays/fht-compositor.nix)
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

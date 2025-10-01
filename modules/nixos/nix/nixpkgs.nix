{ lib, sources, ... }:
let
  inherit (lib) mkDefault;
in {
  nixpkgs = {
    flake.source = sources.nixpkgs;
    hostPlatform = mkDefault "x86_64-linux";
    overlays = [
      (import ../../../overlays/unstable.nix)
      (import ../../../overlays/nix-topology.nix)
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

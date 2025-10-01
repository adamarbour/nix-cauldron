final: prev: {
  nix-topology = prev.callPackage "${final.sources."nix-topology"}/pkgs/nix-topology" {};
}

{ system ? builtins.currentSystem }:
let
  sources = import ./npins;
  pkgs = import sources.nixpkgs { inherit system; config = {}; overlays = []; };
  colmena = pkgs.callPackage "${sources.colmena}/package.nix" {};
in pkgs.mkShellNoCC {
  NIX_CONFIG = "extra-experimental-features = nix-command flakes";
  NIX_PATH = "nixpkgs=${pkgs.path}";
  
  packages = with pkgs; [
    age
    codex
    colmena
    disko
    git
    just
    nix-output-monitor
    nixos-anywhere
    nixos-install
    nixos-rebuild
    npins
    sops
    ssh-to-age
    pciutils
    usbutils
    wireguard-tools
  ];
}

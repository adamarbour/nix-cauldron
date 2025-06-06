{ system ? builtins.currentSystem }:
let
  sources = import ./npins;
  pkgs = import sources.nixpkgs { inherit system; config = {}; overlays = []; };
  
  colmena = pkgs.callPackage "${sources.colmena}/package.nix" { };
  nixvim = import sources.nixvim { inherit system; };
in pkgs.mkShellNoCC {
  NIX_CONFIG = "extra-experimental-features = nix-command flakes";
  
  shellHook = ''
    git config user.name "Adam Arbour"
    git config user.email "845679+adamarbour@users.noreply.github.com"
    git config init.defaultBranch main
  '';
  
  packages = with pkgs; [
    age
    colmena
    disko
    efibootmgr
    git
    just
    nh
    npins
    nixos-anywhere
    nixos-install
    nixos-rebuild
    nixvim.nvimPackage
    nvd
    sbctl
    sops
    ssh-to-age
    yq-go
  ];
}

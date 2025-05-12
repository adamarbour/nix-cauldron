{ lib, config, inputs, ... }:
let

  cfg = config.cauldron.programs;
in {
  imports = [
    ./comodoro.nix
    ./flameshot.nix
    ./git.nix
    ./himalaya.nix
    ./libreoffice.nix
    ./ms-edge.nix
    ./obs-studio.nix
    ./obsidian.nix
    ./opera.nix
    ./slack-term.nix
    ./steam.nix
  ];
}
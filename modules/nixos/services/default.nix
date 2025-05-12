{ lib, config, inputs, ... }:
let
  cfg = config.cauldron.services;
in {
  imports = [
    ./flatpak.nix
    ./fstrim.nix
    ./lightdm.nix
    ./openssh.nix
    ./redshift.nix
    ./tailscale.nix
    ./xfce.nix
    ./xserver.nix
  ];
}
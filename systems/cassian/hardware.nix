{ config, lib, pkgs, ... }:
let
  inherit (lib) mkDefault;
in {
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/0009c1f4-af2c-406a-8537-62f55c960b2f";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/0A57-A5D3";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/9774496f-c938-43fc-8dfe-d7c6785753f2"; }
  ];

}

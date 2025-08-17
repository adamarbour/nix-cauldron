{ config, lib, pkgs, ... }:
let
  inherit (lib) mkDefault;
in {
  # Nvidia A2000 GFX card
  hardware = {
    nvidia.prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
  
  # Make SteamLibrary accessible to steam user
  systemd.tmpfiles.rules = [
    "d /games 0775 steam users - -"
    "d /games/SteamLibrary 0775 steam users - -"
  ];
  
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/61ba0640-2742-4d4c-a794-b3ebb4d3eeaf";
    fsType = "ext4";
    options = [ "noatime" "nodiratime" "discard" ];
  };
  
  fileSystems."/games" = {
    device = "/dev/disk/by-label/GAMES";
    fsType = "ext4";
    options = [ "noatime" "nodiratime" "discard" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/8656-893C";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [ ];
}

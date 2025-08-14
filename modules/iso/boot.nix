{ lib, ... }:
let
  inherit (lib) mkAfter mkForce;
in {
  boot = {
    kernelParams = mkAfter [
      "noquiet"
      "toram"
    ];
    
    # have no need for systemd-boot
    loader.systemd-boot.enable = mkForce false;
    # we don't need to have any raid tools in our system
    swraid.enable = mkForce false;
    
    supportedFilesystems = mkForce [
      "btrfs"
      "vfat"
      "f2fs"
      "xfs"
      "ntfs"
      "cifs"
    ];
  };
}

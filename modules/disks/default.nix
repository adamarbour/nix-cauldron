{ lib, sources, ...}:
let
  inherit (lib) types mkEnableOption mkOption;
in {
  imports = [
    (sources.disko + "/module.nix")
  ] ++ (with builtins; map (fn: ./${fn}) (filter (fn: fn != "default.nix") (attrNames (readDir ./.))));
  
  options.cauldron.host.disk = {
    enable = mkEnableOption "Automatic boot drive partitioning.";
    encrypt = mkEnableOption "Encrypt the root and swap partitions.";
    rootFs = mkOption {
      type = types.enum [
        "ext4"
        "btrfs"
        "zfs"
      ];
      default = "ext4";
      description = "The filesystem type for the boot drive.";
    };
    device = mkOption {
      type = types.str;
      description = "The boot device to format and partition.";
    };
    swap = {
      enable = mkEnableOption "Add swap partition.";
      size = mkOption {
        type = types.str;
        description = "Size in (G) to make the swap partition (sgdisk format).";
        default = "2G";
      };
      resume = mkEnableOption "Support hibernation.";
    };
    impermanence = {
      enable = mkEnableOption "Erase your darlings (using tmpfs).";
      rootSize = mkOption {
        type = types.str;
        description = "Tmpfs root filesize (sgdisk format).";
        default = "1G";
      };
    };
  };
}

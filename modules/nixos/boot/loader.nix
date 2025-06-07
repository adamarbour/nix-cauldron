{ lib, pkgs, config, ...}:
let
  inherit (lib) mkForce mkOption mkDefault mkMerge mkIf mkEnableOption mkPackageOption;
  inherit (lib.types) enum nullOr str;
  cfg = config.cauldron.host.boot;
in {
  options.cauldron.host.boot = {
    loader = mkOption {
      type = enum [
        "none"
        "grub"
        "systemd-boot"
      ];
      default = "none";
      description = "The bootloader that should be used for the device.";
    };
    grub = {
      device = mkOption {
        type = nullOr str;
        default = "nodev";
        description = "The device to install the bootloader to.";
      };
    };
    memtest = {
      enable = mkEnableOption "memtest86+";
      package = mkPackageOption pkgs "memtest86plus" { };
    };
  };
  
  config = mkMerge [
    # NONE
    (mkIf (cfg.loader == "none") {
      boot.loader = {
        grub.enable = mkForce false;
        systemd-boot.enable = mkForce false;
      };
    })
    # GRUB
    (mkIf (cfg.loader == "grub") {
      boot.loader.grub = {
        enable = mkDefault true;
        configurationLimit = 3;
        useOSProber = mkDefault false;
        efiSupport = true;
        enableCryptodisk = mkDefault false;
        inherit (cfg.grub) device;
        theme = null;
        backgroundColor = null;
        splashImage = null;
      };
    })
    # SYSTEMD
    (mkIf (cfg.loader == "systemd-boot") {
      boot.loader.systemd-boot = {
        enable = mkDefault true;
        configurationLimit = 3;
        consoleMode = mkDefault "max";
      };
    })
    # MEMTEST
    (mkIf cfg.memtest.enable {
      boot.loader.systemd-boot = {
        extraFiles."efi/memtest86plus/memtest.efi" = "${cfg.memtest.package}/memtest.efi";
        extraEntries."memtest86plus.conf" = ''
          title MemTest86+
          efi   /efi/memtest86plus/memtest.efi
        '';
      };
    })
  ];
}

{ lib, pkgs, config, sources, ... }:
let
  inherit (lib) types mkMerge mkIf mkOption mkEnableOption mkPackageOption mkForce mkDefault;
  cfg = config.cauldron.host.boot;
in {
  imports = [
    ((import sources.lanzaboote).nixosModules.lanzaboote)
  ];
  
  options.cauldron.host.boot = {
    loader = mkOption {
      type = types.enum [
        "none"
        "grub"
        "systemd"
        "secure"
      ];
      default = "none";
      description = "The bootloader that should be used for the device.";
    };
    grub = {
      device = mkOption {
        type = types.nullOr types.str;
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
    (mkIf (cfg.loader == "none") {
      boot.loader = {
        grub.enable = mkForce false;
        systemd-boot.enable = mkForce false;
      };
    })
    
    (mkIf (cfg.loader == "grub") {
      boot.loader.grub = {
        enable = mkDefault true;
        useOSProber = mkDefault false;
        efiSupport = true;
        enableCryptodisk = mkDefault false;
        inherit (cfg.grub) device;
        theme = null;
        backgroundColor = null;
        splashImage = null;
      };
    })
    
    (mkIf (cfg.loader == "systemd") {
      boot.loader.systemd-boot = {
        enable = mkDefault true;
        consoleMode = mkDefault "max"; # the default is "keep"
        editor = false;
      };
    })
    
    (mkIf (cfg.loader == "secure") {
      environment.systemPackages = [
        pkgs.sbctl
      ];
      boot = {
        loader.grub.enable = mkForce false;
        loader.systemd-boot.enable = mkForce false;
        bootspec.enable = true;
        lanzaboote = {
          enable = true;
          pkiBundle = "/var/lib/sbctl";
        };
      };
    })
    
    (mkIf (cfg.memtest.enable) {
      boot.loader.systemd-boot = {
        extraFiles."efi/memtest86plus/memtest.efi" = "${cfg.boot.memtest.package}/memtest.efi";
        extraEntries."memtest86plus.conf" = ''
          title MemTest86+
          efi   /efi/memtest86plus/memtest.efi
        '';
      };
    })
  ];
}

{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.make.host.boot;
in {

  options.make.host.boot.grub = {
    enable = mkOption {
      type = types.bool;
      default = cfg.loader == "grub";
      description = "Whether to enable GRUB bootloader";
    };

    device = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "/dev/sda";
      description = "Device to install GRUB to";
    };
    
    efiSupport = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable EFI support";
    };

    configurationLimit = mkOption {
      type = types.int;
      default = 5;
      description = "Maximum number of NixOS generations to show in the boot menu";
    };
    
    useOSProber = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to use os-prober to detect other operating systems";
    };
    
    theme = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = "GRUB theme package to use";
      example = "pkgs.nixos-grub2-theme";
    };
    
    fontSize = mkOption {
      type = types.int;
      default = 16;
      description = "Font size for GRUB menu";
    };
    
    extraEntries = mkOption {
      type = types.lines;
      default = "";
      description = "Extra GRUB entries";
      example = ''
        menuentry "Windows" {
          chainloader /EFI/Microsoft/Boot/bootmgfw.efi
        }
      '';
    };
  };

  config = mkIf cfg.grub.enable {
    boot.loader = {
      timeout = cfg.timeout;
      grub = {
        enable = true;
        device = cfg.grub.device;
        efiSupport = cfg.grub.efiSupport;
        useOSProber = cfg.grub.useOSProber;
        theme = cfg.grub.theme;
        fontSize = cfg.grub.fontSize;
        extraEntries = cfg.grub.extraEntries;
        configurationLimit = cfg.grub.configurationLimit;
      };
    };
  };
}
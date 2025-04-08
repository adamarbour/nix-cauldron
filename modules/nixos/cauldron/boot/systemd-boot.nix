{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.make.host.boot;
in {

  options.make.host.boot.systemd = {
    enable = mkOption {
      type = types.bool;
      default = cfg.loader == "systemd-boot";
      description = "Whether to enable systemd-boot bootloader";
    };
    
    editor = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to allow editing the kernel command line before boot";
    };
    
    configurationLimit = mkOption {
      type = types.int;
      default = 5;
      description = "Maximum number of NixOS generations to show in the boot menu";
    };
    
    memtest86 = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to add a memtest86 entry to the boot menu";
    };
    
    extraEntries = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          path = mkOption {
            type = types.str;
            description = "Path to the EFI executable";
          };
          
          text = mkOption {
            type = types.lines;
            description = "Content of the loader entry file";
          };
        };
      });
      default = {};
      description = "Extra loader entries";
      example = literalExpression ''
        {
          "windows.conf" = {
            path = "/boot/loader/entries/windows.conf";
            text = '''
              title Windows
              efi /EFI/Microsoft/Boot/bootmgfw.efi
            ''';
          };
        }
      '';
    };
  };

  config = mkIf cfg.systemd.enable {
    boot.loader = {
      timeout = cfg.timeout;
      systemd-boot = {
        enable = true;
        editor = cfg.systemd.editor;
        configurationLimit = cfg.systemd.configurationLimit;
        memtest86.enable = cfg.systemd.memtest86;
      };
      efi.canTouchEfiVariables = true;
    };
    
    # Add extra loader entries
    environment.etc = mapAttrs' (name: value: 
      nameValuePair "loader/entries/${name}" { 
        source = pkgs.writeText name value.text; 
      }
    ) cfg.systemd.extraEntries;
  };
}
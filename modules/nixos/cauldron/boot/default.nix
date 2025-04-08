{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.make.host.boot;
in {
  imports = [
  ] ++ (with builtins; map (fn: ./${fn}) (filter (fn: fn != "default.nix") (attrNames (readDir ./.))));

  options.make.host.boot = {
    loader = mkOption {
      type = types.enum [ "grub" "systemd-boot" "none" ];
      default = "systemd-boot";
      description = "Which bootloader to use";
    };

    timeout = mkOption {
      type = types.int;
      default = 5;
      description = "Boot menu timeout in seconds";
    };

    consoleMode = mkOption {
      type = types.enum [ "auto" "max" "keep" ];
      default = "keep";
      description = "Console mode to set during boot";
    };

    kernelParams = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Extra kernel parameters to add";
      example = [ "quiet" "splash" "nomodeset" ];
    };
  };

  config = {
    boot = {
      consoleLogLevel = 3;
      kernelParams = cfg.kernelParams;
      # whether to enable support for Linux MD RAID arrays
      # as of 23.11>, this throws a warning if neither MAILADDR nor PROGRAM are set
      swraid.enable = mkDefault false;
      # Ensure a clean & sparkling /tmp on fresh boots.
      tmp.cleanOnBoot = mkDefault true;
    };
  };
}
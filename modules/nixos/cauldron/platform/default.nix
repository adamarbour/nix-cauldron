{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.make.system;
in {
  imports = [];

  options.make.system = {
    type = mkOption {
      type = types.str;
      description = ''
        The complete system triplet or quadruplet (e.g., "x86_64-linux").
        This is a convenience option that overrides individual settings.
      '';
      default = null;
      example = "aarch64-linux";
    };

    allowUnfree = mkOption {
      type = types.bool;
      description = "Whether to allow unfree packages.";
      default = true;
    };
    
    allowBroken = mkOption {
      type = types.bool;
      description = "Whether to allow broken packages.";
      default = false;
    };
  };

  config = {
    nixpkgs.hostPlatform = cfg.type;
    nixpkgs.config = {
      allowUnfree = cfg.allowUnfree;
      allowUnfreePredicate = _: cfg.allowUnfree;
      allowBroken = cfg.allowBroken;
    };
  };
}
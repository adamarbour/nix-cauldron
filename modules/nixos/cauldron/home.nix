{ flake, config, lib, pkgs, inputs, ... }:
with lib;
let
  cfg = config.make.home;
in {

  options.make.home = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable home-manager";
    };
  };

  config = mkIf cfg.enable {
    home-manager = {
      verbose = true;
      useUserPackages = true;
      useGlobalPkgs = true;
      backupFileExtension = "bak";

      extraSpecialArgs = { inherit self inputs; };
      sharedModules = [ flake.homeModules.shared ];
    };
  };
}
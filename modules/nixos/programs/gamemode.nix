{ lib, pkgs, config, ...}:
let
  inherit (lib) mkIf mkDefault;
  profiles = config.cauldron.profiles;
in {
  config = mkIf (lib.elem "gaming" profiles) {
    programs.gamemode = {
      enable = mkDefault true;
      enableRenice = mkDefault true;
      settings = {
        general = {
          softrealtime = "auto";
          renice = 15;
        };
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
        };
      };
    };
  };
}

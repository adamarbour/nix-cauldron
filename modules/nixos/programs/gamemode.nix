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
          inhibit_screensaver = 1;
        };
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
        };
        custom = {
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
        };
      };
    };
    environment.systemPackages = with pkgs.unstable; [ gamemode ];
  };
}

{ lib, pkgs, config, ...}:
let
  inherit (lib) mkIf mkDefault;
  profiles = config.cauldron.profiles;
in {
  config = mkIf (lib.elem "gaming" profiles) {
    programs.steam = {
      enable = mkDefault true;
      gamescopeSession = {
        enable = mkDefault true;
        args = [
          "--adaptive-sync"
          "--rt"
          "--gamepad-as-mouse"
          "--steam"
        ];
      };
      package = pkgs.unstable.steam.override {
        extraEnv = {
          MANGOHUD = true;
          RADV_TEX_ANISO = 16;
        };
        extraLibraries = p: with p; [
          atk
        ];
      };
      protontricks.enable = true;
      remotePlay.openFirewall = true;
      extraCompatPackages = [
        pkgs.unstable.proton-ge-bin.steamcompattool
      ];
      extraPackages = [
        pkgs.unstable.mangohud
      ];
    };
    environment.systemPackages = with pkgs.unstable; [
      protonup-ng
      goverlay
      steamcmd
      mangohud
      # wine
      wineWowPackages.stable
      # wineWowPackages.unstable
      winetricks
      # drm_info
      vulkan-tools
      linuxConsoleTools
    ];
  };
}

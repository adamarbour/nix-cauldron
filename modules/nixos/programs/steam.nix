{ lib, config, pkgs, inputs, ... }:
let

  cfg = config.cauldron.programs.steam;
in {
  # TODO: Handle conditional enablement...
  config = {
    programs.gamemode.enable = true;

    programs.steam = {
      enable = true;

      package = pkgs.steam.override {
        extraEnv = {
          MANGOHUD = true;
          OBS_VKCAPTURE = true;
        };
      };

      gamescopeSession.enable = true;
      protontricks.enable = true;
      extraCompatPackages = with pkgs; [ proton-ge-bin ];

    # dedicatedServer.openFirewall = true; # For hosting games...
    # remotePlay.openFirewall = true;
    };

    environment.systemPackages = with pkgs; [
      mangohud
      mangojuice
      protonup-qt
      (lutris.override {
        extraPkgs = pkgs: [
          pkgs.gamescope
        ];
      })
      (heroic.override {
        extraPkgs = pkgs: [
          pkgs.gamescope
        ];
      })
      bottles
    ];
  };
}
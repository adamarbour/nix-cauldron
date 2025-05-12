{ lib, config, pkgs, inputs, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkEnableOption;

  cfg = config.cauldron.services.xfce;
in {

  options.cauldron.services.xfce = {
    enable =  mkEnableOption "XFCE DE";
  };

  config = mkIf cfg.enable {
    services.displayManager.defaultSession = "xfce";
    
    services.xserver.desktopManager.xfce = {
      enable = true;
      enableScreensaver = true;
      enableXfwm = true;
    };

    environment.systemPackages = with pkgs; [
      xfce.catfish
      xfce.xfdashboard
      xfce.xfce4-datetime-plugin
      xfce.xfce4-docklike-plugin
      xfce.xfce4-mailwatch-plugin
      xfce.xfce4-notes-plugin
      xfce.xfce4-weather-plugin
      xfce.xfce4-whiskermenu-plugin
      xfce.xfce4-windowck-plugin
    ];

    environment.xfce.excludePackages = with pkgs; [
      xfce.xfce4-terminal
    ];

    programs.thunar = {
      enable = true;
      plugins = with pkgs.xfce; [ thunar-archive-plugin thunar-volman ];
    };
    programs.xfconf.enable = true;
  };
}
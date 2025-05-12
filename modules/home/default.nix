{ lib, pkgs, config, inputs, ... }:
{
  imports = with inputs; [
  ### ======= MODULES ======= ###
  ### ======= LOCAL ======= ###
    ./programs
    ./services
  ];

  # let HM manage itself when in standalone mode
  programs.home-manager.enable = true;
  
  # reload system units when changing configs
  systemd.user.startServices = lib.mkDefault "sd-switch";

  # enable xesssion where home-manager is used
  xsession.enable = true;

  home.stateVersion = "24.11"; # Please read the comment before changing.
}

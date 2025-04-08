{ lib, pkgs, osConfig, ... }:
let
  inherit (lib.modules) mkDefault;
in {
  # only available on linux, disabled on macos
  services.ssh-agent.enable = pkgs.stdenv.isLinux;

  home.packages = [ pkgs.cowsay ];

  # reload system units when changing configs
  systemd.user.startServices = mkDefault "sd-switch";

  # let HM manage itself when in standalone mode
  programs.home-manager.enable = true;

  home.stateVersion = "24.11";
}
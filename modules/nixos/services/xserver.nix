{ lib, config, pkgs, inputs, ... }:
let
  inherit (lib.modules) mkForce;

  cfg = config.cauldron.services.xserver;
in {
  # TODO: conditionally enabled...
  options.cauldron.services.xserver = {
    
  };

  config = {
    programs.gdk-pixbuf.modulePackages = [ pkgs.librsvg ];
    services.xserver = {
      enable = true;
      xkb.layout = "us";
      xkb.variant = "";
      
      desktopManager.xterm.enable = mkForce false;
      updateDbusEnvironment = true;
    };
    environment.systemPackages = with pkgs; [
      xclip
      xcolor
      xinput_calibrator
      xorg.setxkbmap
      xorg.xdpyinfo
      xorg.xev
      xorg.xinput
      xorg.xkill
      xorg.xmodmap
      xorg.xprop
      xorg.xrandr
      xorg.xset
      xorg.xwininfo
      wmctrl
      xorg.libxcb
    ];
  };
}

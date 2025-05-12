{ lib, config, pkgs, inputs, ... }:
let

  cfg = config.cauldron.programs.flameshot;
in {
  # TODO: Handle conditional enablement...
  config = {
    environment.systemPackages = with pkgs.unstable; [
      flameshot
      imagemagick
    ];
  };
}
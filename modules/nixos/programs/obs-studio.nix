{ lib, config, pkgs, inputs, ... }:
let

  cfg = config.cauldron.programs.obs-studio;
in {
  # TODO: Handle conditional enablement...
  config = {
   programs.obs-studio = {
    enable = true;
    package = pkgs.unstable.obs-studio;
    plugins = with pkgs.unstable.obs-studio-plugins; [
      obs-backgroundremoval
      obs-ndi
      obs-pipewire-audio-capture
    ];
   };
  };
}
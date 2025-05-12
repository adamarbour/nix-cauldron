{ lib, config, pkgs, inputs, ... }:
let

  cfg = config.cauldron.programs.obsidian;
in {
  # TODO: Handle conditional enablement...
  config = {
    environment.systemPackages = with pkgs.unstable; [
      obsidian
      #vimPlugins.obsidian-nvim
      #rofi-obsidian
    ];
  };
}
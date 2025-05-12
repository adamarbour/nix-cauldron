{ lib, config, pkgs, inputs, ... }:
let

  cfg = config.cauldron.programs.himalaya;
in {
  # TODO: Handle conditional enablement...
  config = {
    environment.systemPackages = with pkgs; [
      himalaya
      neverest
      isync
    #  vimPlugins.himalaya-vim
      oauth2ms
      oauth2-proxy
    ];
  };
}
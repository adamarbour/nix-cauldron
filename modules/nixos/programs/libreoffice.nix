{ lib, config, pkgs, inputs, ... }:
let

  cfg = config.cauldron.programs.libreoffice;
in {
  # TODO: Handle conditional enablement...
  config = {
    environment.systemPackages = with pkgs.unstable; [
      libreoffice-fresh
      hunspell
      hunspellDicts.en_US
    ];
  };
}
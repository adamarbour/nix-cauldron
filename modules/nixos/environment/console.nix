{ lib, config, inputs, ... }:
let
  inherit (lib.modules) mkDefault;

  cfg = config.cauldron.environment;
in {
  config = {
    console = {
      enable = mkDefault true;
      earlySetup = true;
      keyMap = "us";
    };
  };
}
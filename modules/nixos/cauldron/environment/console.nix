{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.make.environment;
in {
  
  options.make.environment = {
    # TODO: Option expansion
  };

  config = {
    console = {
      font = "ter-v22b";
      keyMap = "us";
      packages = [ pkgs.terminus_font ];
      earlySetup = mkDefault true;
    };
  };
}
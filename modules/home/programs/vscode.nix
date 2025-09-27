{ lib, pkgs, ... }:
{
  config = {
    cauldron.packages = {
      inherit (pkgs) vscodium;
    };
    
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
    };
  };
}

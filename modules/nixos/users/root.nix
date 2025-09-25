{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf mkDefault;
in {  
  config = {
    users.users.root = {
      # Initial throwaway password: "nixos"
      initialHashedPassword = mkDefault "$y$j9T$FbXu9/hYPFtVkAy.3JSCs1$XAgWbQs7MbNHP/jH3LRYoxzcwhpQAjY74U7fv40XO94";
      hashedPasswordFile = mkIf config.cauldron.secrets.enable
        config.users.users.${config.cauldron.host.mainUser}.hashedPasswordFile;
    		shell = pkgs.bashInteractive;
    };
  };
}

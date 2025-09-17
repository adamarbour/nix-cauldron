{ lib, pkgs, config, ... }:
let
  inherit (lib) elem mkIf mkDefault;
in {
  config = mkIf (elem "aarbour" config.cauldron.host.users) {
    users.users.aarbour = {
      # Initial throwaway password: "nixos"
      initialHashedPassword = mkDefault "$y$j9T$FbXu9/hYPFtVkAy.3JSCs1$XAgWbQs7MbNHP/jH3LRYoxzcwhpQAjY74U7fv40XO94";
      openssh.authorizedKeys.keyFiles = [
        (builtins.fetchurl {
          url = "https://github.com/adamarbour.keys";
          sha256 = "sha256-yT6FMVq81ASQo2ILGOl3pwYuyDf8SM+QUdhoDH6bdOA=";
        })
      ];
    };
  };
}

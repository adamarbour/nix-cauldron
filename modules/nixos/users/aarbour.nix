{ lib, pkgs, config, ... }:
let
  inherit (lib) elem mkIf mkDefault;
in {
  config = mkIf (elem "aarbour" config.cauldron.host.users) {
    users.users.aarbour = {
      # Initial throwaway password: "nixos"
      initialHashedPassword = mkDefault "$y$j9T$FbXu9/hYPFtVkAy.3JSCs1$XAgWbQs7MbNHP/jH3LRYoxzcwhpQAjY74U7fv40XO94";
    };
  };
}

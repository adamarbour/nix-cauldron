{ lib, config, inputs, ... }:
let
  inherit (lib.modules) mkDefault;

  cfg = config.cauldron.environment;
in {

  imports = [
    (lib.mkAliasOptionModule [ "cauldron" "environment" "hostPlatform" ] [ "nixpkgs" "hostPlatform" ])
  ];

  config = {

  };
}
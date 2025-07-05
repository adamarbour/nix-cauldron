let
  sources = import ./npins;
  pkgs = import sources.nixpkgs {};
  lib = pkgs.lib;
  makeHive =
    rawHive:
    (import "${sources.colmena}/src/nix/hive/eval.nix" {
      inherit rawHive;
      colmenaOptions = import "${sources.colmena}/src/nix/hive/options.nix";
      colmenaModules = import "${sources.colmena}/src/nix/hive/modules.nix";
    });
in
lib.mapAttrs (name: value: {
  nixos-system = value.config.system.build.toplevel;
  disko-script = value.config.system.build.diskoScriptNoDeps;
}) (makeHive (import ./hive.nix)).nodes
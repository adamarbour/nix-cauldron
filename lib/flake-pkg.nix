{ pkgs, src }:
let
	flake = builtins.getFlake src;
	system = pkgs.stdenv.hostPlatform.system;
in flake.packages.${system}

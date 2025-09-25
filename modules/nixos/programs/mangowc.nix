{ lib, pkgs, config, ... }:
let
	inherit (lib) mkIf;
	inherit (lib.cauldron) anyHome;
	enable = anyHome config (conf: conf.programs.mangowc.enable or false);
in {
	config = mkIf enable {
		cauldron.packages = {
			inherit (pkgs) mangowc xdg-utils;
		};
	};
}

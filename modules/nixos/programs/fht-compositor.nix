{ lib, pkgs, config, ... }:
let
	inherit (lib) mkIf;
	inherit (lib.cauldron) anyHome;
	enable = anyHome config (conf: conf.programs.fht-compositor.enable or false);
in {
	config = mkIf enable {
		cauldron.packages = {
			inherit (pkgs) fht-compositor fht-share-picker xdg-utils;
		};
	};
}

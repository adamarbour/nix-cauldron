{ lib, config, ... }:
let
  inherit (lib) mkIf mkDefault;
  inherit (lib.cauldron) hasProfile;
in {
	config = mkIf (!hasProfile config "container") {
  		# enable smartd monitoring
  		services.smartd.enable = mkDefault true;
	};
}

final: prev:
let
	sources = import ../npins;
in {
	unstable = import sources.nixpkgs-unstable {
	  inherit (prev.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };
}

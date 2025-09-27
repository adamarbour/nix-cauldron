final: prev:
let
	sources = import ../npins;
in {
	unstable = import sources.nixpkgs-unstable {
    config.allowUnfree = true;
  };
}

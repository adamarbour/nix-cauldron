final: prev:
let
	sources = import ../npins;
	fhtPkgs = (import ../lib/flake-pkg.nix {
		pkgs = prev; src = sources.fht-compositor.url;
	});
	fhtExtraPkgs = (import ../lib/flake-pkg.nix {
		pkgs = prev; src = sources.fht-share-picker.url;
	});
in {
	fht-compositor = fhtPkgs.default or fhtPkgs.fht-compositor;
	fht-share-picker = fhtExtraPkgs.default or fhtExtraPkgs.fht-share-picker;
}

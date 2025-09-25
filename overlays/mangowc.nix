final: prev:
let
	sources = import ../npins;
	mangoPkgs = (import ../lib/flake-pkg.nix {
		pkgs = prev; src = sources.mangowc.url;
	});
in {
	mangowc = mangoPkgs.default or mangoPkgs.mangowc or mangoPkgs.mango;
}

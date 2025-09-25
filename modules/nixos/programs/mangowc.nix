{ pkgs, sources, ... }:
{
	# TODO: Handle conditions for this ...
  cauldron.packages = {
  		inherit (pkgs) mangowc;
  };
}

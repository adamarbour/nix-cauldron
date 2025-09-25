{ pkgs, sources, ... }:
{
	# TODO: Handle conditions for this ...
  cauldron.packages = {
  		inherit (pkgs) fht-compositor fht-share-picker xdg-utils;
  };
}

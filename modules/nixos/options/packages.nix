{ lib, config, _class, ... }:
let
  inherit (lib) mkOption types mergeAttrsList optionalAttrs;
  cfg = config.cauldron;
in {
  options.cauldron = {
    packages = mkOption {
    		type = types.attrsOf types.package;
    		default = { };
    		description = "A set of packages to install in the environment.";
    };
  };
  config = mergeAttrsList [
  		(optionalAttrs (_class == "nixos") {
  			environment.systemPackages = builtins.attrValues cfg.packages;
  		})
  		(optionalAttrs (_class == "homeManager") {
  			home.packages = builtins.attrValues cfg.packages;
  		})
  ];
}

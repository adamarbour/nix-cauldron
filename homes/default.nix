{ lib, config, sources, ... }:
let
  inherit (lib) genAttrs;
in {
  imports = [
    "${sources.home-manager}/nixos"
  ];
  
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "old";
    
    users = genAttrs config.cauldron.system.users (name: {
      imports = [ ./${name} ];
    });
    
    extraSpecialArgs = {
      inherit sources;
      cauldron = lib.cauldron;
      osConfig = config;	# Pass in the host config for reference in hm
    };
    sharedModules = [
    		# Pass in the parent lib to hm so it can be used in hm modules
      ({ lib, cauldron, ... }:
        { _module.args.lib = lib.extend (final: prev: {
          cauldron = cauldron;
        });
      })
      ../modules/home
    ];
  };
}

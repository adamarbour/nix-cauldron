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
    
    users = genAttrs config.cauldron.host.users (name: {
      imports = [ ./${name} ];
    });
    
    extraSpecialArgs = {
      inherit sources;
      cauldron = lib.cauldron;
      osConfig = config;
    };
    sharedModules = [
      ({ lib, cauldron, ... }:
        { _module.args.lib = lib.extend (final: prev: {
          cauldron = cauldron;
        });
      })
      ../modules/home
    ];
  };
}

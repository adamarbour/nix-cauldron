{ sources, ... }:
{
  imports = [
    "${sources.home-manager}/nixos"
  ];
  
  home-manager = {
    verbose = true;
    useUserPackages = true;
    useGlobalPkgs = true;
    backupFileExtension = "bak";
    
    extraSpecialArgs = {
      inherit sources;
    };
    
    sharedModules = [
      ./environment
      ./programs
    ];
  };
}

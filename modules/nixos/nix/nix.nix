{ lib, config, sources, ... }:
let
  inherit (lib) mkDefault;
in {
  nix = {
    channel.enable = false;
    optimise.automatic = mkDefault (!config.boot.isContainer);
    
    registry.nixpkgs.to = {
      type = "path";
      path = sources.nixpkgs;
    };
    
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    
    daemonCPUSchedPolicy = mkDefault "batch";
    daemonIOSchedClass = mkDefault "idle";
    daemonIOSchedPriority = mkDefault 7;
  };
  
  systemd.services.nix-gc.serviceConfig = {
    CPUSchedulingPolicy = "batch";
    IOSchedulingClass = "idle";
    IOSchedulingPriority = 7;
  };
}

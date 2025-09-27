{ pkgs, config, ... }:
  primeUser = config.cauldron.system.mainUser;
{
  nix.settings = {
    sandbox = pkgs.stdenv.hostPlatform.isLinux;
    allowed-users = [ "@wheel" ];
    trusted-users = [ "root" "${primeUser}" ];
    
    auto-optimise-store = true;
    keep-derivations = true;
    keep-outputs = true;
    keep-going = true;
    
    max-jobs = "auto";
    cores = 0;
    min-free = 536870912; # 512M
    max-free = 1073741824; # 1GB
    
    http-connections = 50;
    connect-timeout = 10;
    log-lines = 25;
    
    system-features = [
      "uid-range"
    ];
    
    fallback = true;
    
    builders-use-substitutes = true;
    auto-allocate-uids = true;
    
    experimental-features = [
      "auto-allocate-uids"
      "ca-derivations"
      "cgroups"
      "fetch-closure"
    ];
    warn-dirty = false;
    use-xdg-base-directories = true;
  };
}

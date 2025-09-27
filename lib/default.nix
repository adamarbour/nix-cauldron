{ lib, ... }:
let
  inherit (lib) filter hasAttr any getAttrFromPath;
  
  # HARDWARE
  isx86Linux = pkgs: pkgs.stdenv.hostPlatform.isLinux && pkgs.stdenv.hostPlatform.isx86;
  
  # VALIDATORS
  hasProfile = config: profile: builtins.elem profile (config.cauldron.profiles or []);
  ifTheyExist = config: groups: filter (group: hasAttr group config.users.groups) groups;
  anyHome = conf: cond: let
  		list = map (user: getAttrFromPath [ "home-manager" "users" user ] conf) conf.cauldron.system.users;
  		in any cond list;
  		
in {
  inherit
  		# Hardware
  		isx86Linux
  		
  		# Validators
    hasProfile
    ifTheyExist
    anyHome
    ;
}

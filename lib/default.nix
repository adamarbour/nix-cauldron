{ lib, ... }:
let
  inherit (lib) filter hasAttr;
  
  # TODO: Document...
  hasProfile = config: profile: builtins.elem profile (config.cauldron.profiles or []);
  ifTheyExist = config: groups: filter (group: hasAttr group config.users.groups) groups;
in {
  inherit
    hasProfile
    ifTheyExist
    ;
}

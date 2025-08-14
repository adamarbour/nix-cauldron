{ lib, config, ... }:
let
  inherit (lib) mkIf;
  cfg = config.cauldron.secrets;
in {
  imports = [
  ] ++ (with builtins; map (fn: ./${fn}) (filter (fn: fn != "default.nix") (attrNames (readDir ./.))));
  
  config = mkIf cfg.enable {
    sops.secrets = {
      passwd.neededForUsers = true;
    };
  };
}

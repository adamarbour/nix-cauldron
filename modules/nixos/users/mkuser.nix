{ lib, pkgs, config, ... }:
let
  inherit (lib) genAttrs mkDefault mergeAttrsList optionalAttrs;
  inherit (lib.cauldron) ifTheyExist;
in {
  config = {
    users.users = genAttrs config.cauldron.host.users (name:
      mergeAttrsList [
      
        # Secrets are not enabled for this host...
        (optionalAttrs (!config.cauldron.secrets.enable) {
          users.users.${name}.initialPassword = "nixos";
        })
        
        {
          home = "/home/${name}";
          
          uid = mkDefault 1000;
          isNormalUser = true;
          extraGroups = [ "wheel" "nix" ]
          ++ ifTheyExist config [
            "network"
            "networkmanager"
            "systemd-journal"
            "audio"
            "pipewire"
            "video"
            "input"
            "plugdev"
            "lp"
            "tss"
            "power"
            "git"
          ];
        }
        # TODO: Handle impermanence and password from secrets
      ]
    );
  };
}

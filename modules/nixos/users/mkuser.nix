{ lib, pkgs, config, sources, ... }:
let
  inherit (lib) genAttrs mkDefault optionalAttrs mkIf mergeAttrsList;
  inherit (lib.cauldron) ifTheyExist;
  
  secretsRepo = sources.secrets;
  userList = config.cauldron.host.users;
in {
  config = {
    
    ####### SOPS secret declarations (one set per user) ########
    sops.secrets = mkIf config.cauldron.secrets.enable
      (lib.foldl'
        (acc: name:
          let
            sopsFile = "${secretsRepo}/trove/users/${name}.yaml";
          in acc // {
            # Per-user secrets with unique names
            "passwd" = {
              inherit sopsFile;
              owner = "root";
              group = "root";
              mode  = "0400";
            };

            "id_ed25519" = {
              inherit sopsFile;
              owner = name;
              group = "users";
              mode  = "0600";
              # materialize where the user expects it
              path  = "/home/${name}/.ssh/id_ed25519";
            };

            "id_ed25519.pub" = {
              inherit sopsFile;
              owner = name;
              group = "users";
              mode  = "0644";
              path  = "/home/${name}/.ssh/id_ed25519.pub";
            };
          })
        {}
      userList);
    
    ####### Per-user accounts ########
    users.users = genAttrs userList (name: let
      passwdPath = mkIf config.cauldron.secrets.enable
        config.sops.secrets."passwd".path;
      pubKeyString = mkIf config.cauldron.secrets.enable
        (builtins.readFile config.sops.secrets."id_ed25519.pub".path);
    in {
      home = "/home/${name}";
      uid = mkDefault 1000;
      isNormalUser = true;

      extraGroups =
        [ "wheel" "nix" ]
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

      # If secrets are disabled, fall back to a throwaway initial password.
      initialPassword = mkIf (!config.cauldron.secrets.enable) "nixos";
      hashedPasswordFile = passwdPath;
      openssh.authorizedKeys.keys = mkIf config.cauldron.secrets.enable [ pubKeyString ];
    });
    
    ####### Ensure ~/.ssh exists with correct perms ########
    systemd.tmpfiles.rules = lib.concatMap
      (name: [ "d /home/${name}/.ssh 0700 ${name} users -" ])
      userList;
  };
}

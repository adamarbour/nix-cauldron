{ lib, pkgs, config, sources, ... }:
let
  inherit (lib) genAttrs mkDefault optionalAttrs mkIf mergeAttrsList;
  inherit (lib.cauldron) ifTheyExist;
  impermanence = config.cauldron.host.disk.impermanence;
  secretsRepo = sources.secrets;
  userList = config.cauldron.system.users;
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
            "users/${name}/passwd" = {
              inherit sopsFile;
              key = "passwd";
              neededForUsers = true;
            };

            "users/${name}/id_ed25519" = {
              inherit sopsFile;
              key = "id_ed25519";
              owner = name;
              group = "users";
              mode  = "0600";
              # materialize where the user expects it
              path  = "/home/${name}/.ssh/id_ed25519";
            };

            "users/${name}/id_ed25519.pub" = {
              inherit sopsFile;
              key = "id_ed25519.pub";
              owner = name;
              group = "users";
              mode  = "0644";
              path  = "/home/${name}/.ssh/id_ed25519.pub";
            };
          })
        {}
      userList);
    
    ####### Per-user accounts ########
    users.users = genAttrs userList (name: {
      createHome = true;
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

      hashedPasswordFile = mkIf config.cauldron.secrets.enable
        config.sops.secrets."users/${name}/passwd".path;
      openssh.authorizedKeys.keyFiles = mkIf config.cauldron.secrets.enable [
        config.sops.secrets."users/${name}/id_ed25519.pub".path
      ];
    });
    
    ####### Impermanent Sane Defaults ########
    environment.persistence."${config.cauldron.host.impermanence.root}" = mkIf impermanence.enable {
      users = genAttrs userList (name: {
        directories = [
          { directory = "Desktop"; user = "${name}"; group = "users"; }
          { directory = "Documents"; user = "${name}"; group = "users"; }
          { directory = "Downloads"; user = "${name}"; group = "users"; }
          { directory = "Media"; user = "${name}"; group = "users"; }
          { directory = "Projects"; user = "${name}"; group = "users"; }
          { directory = "public"; user = "${name}"; group = "users"; }
        ];
      });
    };
    
    ####### Ensure ~/.ssh exists with correct perms ########
    systemd.tmpfiles.rules = lib.concatMap
      (name: [ "d /home/${name}/.ssh 0700 ${name} users -" ])
      userList;
  };
}

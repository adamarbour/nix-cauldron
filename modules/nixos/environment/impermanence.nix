{ lib, config, sources, ... }:
let
  inherit (lib) types mkIf mkOption mapAttrs' nameValuePair;
  cfg = config.cauldron.host.impermanence;
  
  enableImpermanence = config.cauldron.host.disk.impermanence.enable;
  impermanentUsers = mapAttrs' (u: uCfg:
    nameValuePair u {
      directories = uCfg.extraDirs;
      files = uCfg.extrafiles;
    }
  ) cfg.users;
in {
  imports = [ (sources.impermanence + "/nixos.nix") ];
  
  options.cauldron.host.impermanence = {
    hideMounts = mkOption {
      type = types.bool;
      default = true;
      description = "Use bind mounts to hide persist mountpoints.";
    };
    extra = {
      dirs = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Additional paths (absolute) to persist.";
      };
      files = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Additional files (absolute) to persist.";
      };
    };
    users = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          extraDirs = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Per-user directories (path relative to $HOME) to persist.";
          };
          extraFiles = mkOption {
            type = types.listOf types.str;
            default = [];
            description = "Per-user files (path relative to $HOME) to persist.";
          };
        };
      });
      default = {};
      description = "Per-user persistent entries (relative to /home).";
    };
  };
  
  config = mkIf enableImpermanence {
    fileSystems."/persist".neededForBoot = true;
    environment.persistence."/persist" = {
      hideMounts = cfg.hideMounts;
      directories = [
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/var/lib/NetworkManager"
        "/var/lib/iwd"
        "/var/lib/colord"
        "/var/cache/nix"
      ] ++ cfg.extra.dirs;
      files = [
        "/etc/machine-id"
      ] ++ cfg.extra.files;
      users = impermanentUsers;
    };
    
    programs.fuse.userAllowOther = true;
    
    systemd.tmpfiles.rules = [
      "d /var/log 0755 root root -"
    ];
  };
}

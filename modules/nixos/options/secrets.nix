{ lib, config, sources, ... }:
let
  inherit (lib) types mkEnableOption mkOption;
  
  secretsRepo = sources.secrets;
  cfg = config.cauldron.secrets;
  
  # submodule describing one secret
  secretItemModule = types.submodule ({ config, ... }: {
    options = {
      # If unset, falls back to cfg.defaultFile
      sopsFile = mkOption {
        type = types.nullOr (types.either types.path types.str);
        default = null;
        description = "Optional SOPS file to read this secret from.";
      };

      # For structured files (yaml/json/dotenv), select a key to extract.
      key = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Key within the SOPS file (for yaml/json/dotenv).";
      };

      # Where to write the decrypted secret. If unset, defaults to /run/secrets/<name>.
      path = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Absolute path for the decrypted secret file.";
      };

      owner = mkOption { type = types.str; default = "root"; };
      group = mkOption { type = types.str; default = "root"; };
      mode  = mkOption { type = types.str; default = "0400"; };

      # sops-nix format: one of "binary" "yaml" "json" "dotenv"
      format = mkOption {
        type = types.enum [ "binary" "yaml" "json" "dotenv" ];
        default = "binary";
      };

      # Optional units to restart when this secret changes
      restartUnits = mkOption {
        type = types.listOf types.str;
        default = [];
      };
    };
  });
in {
  options.cauldron.secrets = {
    enable = mkEnableOption "Enable secrets ... shhhh";
     
    # Root of your secrets repo; everything resolves relative to this.
    root = mkOption {
      type = types.path;
      default = sources.secrets;
      description = "Root directory for all relative secret file paths.";
    };
     
    # Override the default SOPS file used when an item doesn't specify sopsFile
    defaultFile = mkOption {
      type = types.path;
      default = "trove/default.yaml";
      description = "Default SOPS file for secrets without an explicit sopsFile (relative to secrets repo)";
    };
     
     # Host specific secret definitions
     items = mkOption {
      type = types.attrsOf secretItemModule;
      default = {};
      example = {
        "db/password" = {
          key = "key.in.defaultFile";
          format = "yaml";
          mode = "0400";
        };
        "aarbour/github-token" = {
          sopsFile = "relative/to/secretsRepo.yaml";
          owner = "USER"; group = "users"; mode = "0400";
          path = "/home/USER/.config/secrets/github-token";
        };
      };
      description = ''
        Declarative secrets. Each item supports per-secret sopsFile, key (for yaml/json/dotenv),
        owner/group/mode, custom output path, and restartUnits.
      '';
     };
  };
}

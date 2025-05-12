{ lib, config, pkgs, inputs, ... }:
let
  inherit (lib.options) mkOption;
  inherit (lib.types) str;

  cfg = config.cauldron.secrets;
  secretsPath = builtins.toString inputs.my-secrets;
in {

  options.cauldron.secrets = {

    defaultSecretsFile = mkOption {
      type = str;
      description = "Path to the base secrets file";
      default = "${secretsPath}/secrets/common.yaml";
    };

  };

  config = {
    sops = {
      defaultSopsFile = cfg.defaultSecretsFile;
      age = {
        sshKeyPaths = [ "/persist/system/etc/ssh/ssh_host_ed25519_key" ];
        generateKey = false;
      };

      secrets = {
        my_password.neededForUsers = true;
      };
    };

    environment.systemPackages = with pkgs; [ 
      sops
      age
      ssh-to-age
    ];
  };
}

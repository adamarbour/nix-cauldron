{ config, lib, pkgs, inputs, ... }:
with lib;
let
  cfg = config.make.secrets;
  secretspath = builtins.toString inputs.my-secrets;
in {
  imports = [
    inputs.sops-nix.nixosModules.default
  ];

  options.make.secrets = {
    enable = mkEnableOption "sops-nix secrets management";

    baseSecretsFile = mkOption {
      type = types.str;
      description = "Path to the base secrets file";
      default = "${secretspath}/secrets/common.yaml";
    };
  };

  config = mkIf cfg.enable {
    sops = {
      defaultSopsFile = cfg.baseSecretsFile;
      age = {
        sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        keyFile = "/var/lib/sops-nix/key.txt";
        generateKey = true;
      };
    };
  };
}
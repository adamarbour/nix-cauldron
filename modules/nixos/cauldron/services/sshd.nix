{ config, lib, pkgs, inputs, ... }:
with lib;
let
  cfg = config.make.services.sshd;
in {

  options.make.services.sshd = {
    enable = mkOption {
      type = types.bool;
      description = "Whether to enable openssh-server.";
      default = false;
    };
    enableSFTP = mkOption {
      type = types.bool;
      description = "Whether to enable sftp over ssh.";
      default = true;
    };
    permitRoot = mkOption {
      type = types.bool;
      description = "Whether to enable root access over ssh.";
      default = false;
    };
  };
  
  config = {
    services.sshguard.enable = cfg.enable;
    services.openssh = {
      enable = cfg.enable;
      settings.PermitRootLogin = "yes";
      startWhenNeeded = cfg.enable;
      allowSFTP = cfg.enableSFTP;
      openFirewall = cfg.enable;
      ports = [ 22 443 ];
      hostKeys = [
        {
          bits = 4096;
          path = "/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
        }
        {
          bits = 4096;
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };
  };
}
{ lib, pkgs, config, ... }:
let
  inherit (lib) mkMerge mkForce mkDefault;
  profiles = config.cauldron.profiles;
in {
  config = {
    services.fail2ban = {
      enable = if (lib.elem "server" profiles) then true else false;
      maxretry = 5;
      bantime = "1h";
      ignoreIP = [
        "127.0.0.0/8"
        "10.0.0.0/8"
        "192.168.0.0/16"
        "172.31.0.0/16"
      ];
      jails = mkMerge [
        {
          sshd = mkForce ''
            enabled = true
            port = ${lib.concatStringsSep "," (map toString config.services.openssh.ports)}
            mode = aggressive
          '';
        }
      ];
      bantime-increment = {
        enable = true;
        rndtime = "12m";
        multipliers = "4 8 16 32 64 128 256 512 1024 2048";
        maxtime = "192h";
        overalljails = true; # Calculate the bantime based on all the violations
      };
    };
  };
}

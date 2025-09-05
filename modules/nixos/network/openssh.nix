{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf mkMerge mkDefault;
  impermanence = config.cauldron.host.disk.impermanence;
  persistRoot = if (impermanence.enable) then config.cauldron.host.impermanence.root else "";
  
  profiles = config.cauldron.profiles;
in {
  config = mkMerge [
    (mkIf impermanence.enable {
      cauldron.host.impermanence.extra = {
        files = [
          "/etc/ssh/ssh_host_rsa_key"
          "/etc/ssh/ssh_host_ed25519_key"
        ];
      };
    })
    
    {
      services.openssh = {
        enable = true;
        startWhenNeeded = if (lib.elem "server" profiles) then false else true;
        allowSFTP = true;
        openFirewall = true;
        ports = [ 22 ];
        
        settings = {
          # Don't allow root login
          PermitRootLogin = "no";
          
          AuthenticationMethods = "publickey";
          PubkeyAuthentication = "yes";
          PasswordAuthentication = false;
          PermitEmptyPasswords = false;
          PermitTunnel = false;
          UseDns = false;
          UsePAM = false;
          ChallengeResponseAuthentication = "no";
          KbdInteractiveAuthentication = false;
          X11Forwarding = config.services.xserver.enable;
          MaxAuthTries = 3;
          MaxSessions = 2;
          TCPKeepAlive = false;
          AllowTcpForwarding = false;
          AllowAgentForwarding = false;
          LogLevel = "VERBOSE";
          
          KexAlgorithms = [
            "curve25519-sha256@libssh.org"
            "ecdh-sha2-nistp521"
            "ecdh-sha2-nistp384"
            "ecdh-sha2-nistp256"
            "diffie-hellman-group-exchange-sha256"
          ];
          Ciphers = [
            "chacha20-poly1305@openssh.com"
            "aes256-gcm@openssh.com"
            "aes128-gcm@openssh.com"
            "aes256-ctr"
            "aes192-ctr"
            "aes128-ctr"
          ];
          Macs = [
            "hmac-sha2-512-etm@openssh.com"
            "hmac-sha2-256-etm@openssh.com"
            "umac-128-etm@openssh.com"
            "hmac-sha2-512"
            "hmac-sha2-256"
            "umac-128@openssh.com"
          ];

          # kick out inactive sessions
          ClientAliveCountMax = 5;
          ClientAliveInterval = 60;
        };
        
        hostKeys = [
          {
            bits = 4096;
            path = "${persistRoot}/etc/ssh/ssh_host_rsa_key";
            type = "rsa";
          }
          {
            bits = 4096;
            path = "${persistRoot}/etc/ssh/ssh_host_ed25519_key";
            type = "ed25519";
          }
        ];
      };
    }
  ];
}

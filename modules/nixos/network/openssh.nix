{ lib, pkgs, config, ... }:
let
  inherit (lib) mkDefault;
  profiles = config.cauldron.profiles;
  persistRoot = if config.cauldron.impermanence.enable then "/persist/system" else ""; 
  isGraphical = (lib.elem "graphical" profiles);
in {
  config = {
    programs.mosh.enable = isGraphical;
    programs.ssh = {
      startAgent = isGraphical;
      hostKeyAlgorithms = [ "ssh-ed25519" "ssh-rsa" ];

      extraConfig = ''
        Host * 
          IdentityFile ${persistRoot}/etc/ssh/ssh_host_ed25519_key
          IdentityFile ~/.ssh/id_ed25519
      '';
    };
    
    services.openssh = {
      enable = mkDefault true;
      startWhenNeeded = mkDefault true;
      allowSFTP = mkDefault true;
      openFirewall = true;
      ports = [ 22 ];
      
      settings = {
        # Don't allow root login
        PermitRootLogin = "no";
        
        # only allow key based logins and not password
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        AuthenticationMethods = "publickey";
        PubkeyAuthentication = "yes";
        ChallengeResponseAuthentication = "no";
        UsePAM = false;
        UseDns = false;
        X11Forwarding = false;
        
        # Use key exchange algorithms recommended by `nixpkgs#ssh-audit`
        KexAlgorithms = [
          "curve25519-sha256"
          "curve25519-sha256@libssh.org"
          "diffie-hellman-group16-sha512"
          "diffie-hellman-group18-sha512"
          "sntrup761x25519-sha512@openssh.com"
          "diffie-hellman-group-exchange-sha256"
          "mlkem768x25519-sha256"
          "sntrup761x25519-sha512"
        ];
        
        # Use Macs recommended by `nixpkgs#ssh-audit`
        Macs = [
          "hmac-sha2-512-etm@openssh.com"
          "hmac-sha2-256-etm@openssh.com"
          "umac-128-etm@openssh.com"
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
  };
}

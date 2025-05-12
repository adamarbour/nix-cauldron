{ lib, config, inputs, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) enum;
  inherit (config.services) tailscale;

  cfg = config.cauldron.services.ssh;
in {
  
  options.cauldron.services.ssh = {
    
  };

  config = {
   services.openssh = {
    enable = true;
    startWhenNeeded = true;
    openFirewall = true;
    # the port(s) openssh daemon should listen on
    ports = [ 22 ];
    allowSFTP = true;
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
        path = "/persist/system/etc/ssh/ssh_host_rsa_key";
        type = "rsa";
      }
      {
        bits = 4096;
        path = "/persist/system/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];
   }; 
  };
}
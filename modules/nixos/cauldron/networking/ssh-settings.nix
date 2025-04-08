{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.make.host.networking;
in {
  config = {
    boot.initrd.network.ssh.authorizedKeyFiles = with inputs; [ my-keys.outPath ];
    services.openssh.settings = {
      # Use only SSH protocol version 2
      Protocol = "2";
      # Enforce key-based authentication by disabling password logins
      PasswordAuthentication = false;
      ChallengeResponseAuthentication = "no";
      # Do not allow empty passwords
      PermitEmptyPasswords = "no";
      # Disable X11 forwarding for additional security
      X11Forwarding = false;
      # Limit the number of authentication attempts per connection
      MaxAuthTries = "4";
      KbdInteractiveAuthentication = false;
      AuthenticationMethods = "publickey";
      UsePAM = false;
      UseDns = false;
      # unbind gnupg sockets if they exists
      StreamLocalBindUnlink = true;
      Ciphers = [
        "chacha20-poly1305@openssh.com"
        "aes256-gcm@openssh.com"
        "aes256-ctr"
        "aes192-ctr"
        "aes128-ctr"
      ];
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
      # Configure client keep-alive to terminate inactive sessions
      ClientAliveCountMax = 5;
      ClientAliveInterval = 60;
    };
  };
}
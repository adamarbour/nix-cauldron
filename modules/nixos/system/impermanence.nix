{ lib, config, sources, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  
  cfg = config.cauldron.impermanence;
in {
  imports = [
    (sources.impermanence + "/nixos.nix")
  ];
  options.cauldron.impermanence = {
    enable = mkEnableOption "Enable bind-mounted impermanence for the system";
  };
  
  config = mkIf cfg.enable {
    fileSystems."/persist".neededForBoot = true;
    fileSystems."/var/log".neededForBoot = true;
    programs.fuse.userAllowOther = true;
    
    environment.persistence."/persist/system" = {
      hideMounts = true;
      directories = [
        "/var/lib/bluetooth"
        "/var/lib/iwd"
        "/var/lib/nixos"
        "/var/lib/sbctl"
        "/var/lib/systemd"
      ];
      files = [
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
      ];
    };
    # TODO: Make this configurable...
    environment.persistence."/persist/users" = {
      hideMounts = true;
      directories = [
        "/home/aarbour"
      ];
    };
  };
}

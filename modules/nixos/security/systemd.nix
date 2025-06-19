{ lib, config, ... }:
let
  inherit (lib) mkDefault;
in {
  config = {
    # Add "proc" group to whitelist /proc access and allow systemd-logind to view
    # /proc in order to unbreak it, as well as to user@ for similar reasons.
    # See https://github.com/systemd/systemd/issues/12955, and https://github.com/Kicksecure/security-misc/issues/208
    users.groups.proc.gid = config.ids.gids.proc;
    systemd.services.systemd-logind.serviceConfig.SupplementaryGroups = [ "proc" ];
    systemd.services."user@".serviceConfig.SupplementaryGroups = [ "proc" ];
    
    # Don't store coredumps from systemd-coredump.
    systemd.coredump.extraConfig = ''
      Storage=none
    '';
    
    # Enable IPv6 privacy extensions for systemd-networkd.
    systemd.network.config.networkConfig.IPv6PrivacyExtensions = mkDefault "kernel";
    
    systemd.tmpfiles.settings = {
      # Make all files in /etc/nixos owned by root, and only readable by root.
      # /etc/nixos is not owned by root by default, and configuration files can
      # on occasion end up also not owned by root. This can be hazardous as files
      # that are included in the rebuild may be editable by unprivileged users,
      # so this mitigates that.
      "restrictetcnixos"."/etc/nixos/*".Z = {
        mode = mkDefault "0000";
        user = mkDefault "root";
        group = mkDefault "root";
      };
      # Restrict permissions of /home/$USER so that only the owner of the
      # directory can access it (the user). systemd-tmpfiles also has the benefit
      # of recursively setting permissions too, with the "Z" option as seen below.
      "restricthome"."/home/*".Z.mode = mkDefault "~0700";
    };
  };
}

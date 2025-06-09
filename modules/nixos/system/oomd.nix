{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf mkForce concatStringsSep;
  profiles = config.cauldron.profiles;
  
  avoid = concatStringsSep "|" [
    "(h|H)yprland"
    "sway"
    "qtile"
    "Xwayland"
    "cryptsetup"
    "dbus-.*"
    "gpg-agent"
    "greetd"
    "ssh-agent"
    ".*qemu-system.*"
    "sddm"
    "sshd"
    "systemd"
    "systemd-.*"
    "kitty"
    "bash"
    "zsh"
    "fish"
    "n?vim"
    "akkoma"
  ];

  prefer = concatStringsSep "|" [
    "Web Content"
    "Isolated Web Co"
    "firefox.*"
    "chrom(e|ium).*"
    "electron"
    "dotnet"
    ".*.exe"
    "java.*"
    "pipewire(.*)"
    "nix"
    "npm"
    "node"
    "pipewire(.*)"
  ];
in
{
  config = mkIf (lib.elem "graphical" profiles) {
    systemd.oomd.enable = mkForce false;
    services = {
      earlyoom = {
        enable = true;
        enableNotifications = true;
        
        reportInterval = 0;
        freeSwapThreshold = 5;
        freeSwapKillThreshold = 2;
        freeMemThreshold = 5;
        freeMemKillThreshold = 2;
        
        extraArgs = [
          "-g"
          "--avoid"
          "'^(${avoid})$'" # things that we want to avoid killing
          "--prefer"
          "'^(${prefer})$'" # things we want to remove fast
        ];
        
        # we should ideally write the logs into a designated log file; or even better, to the journal
        # for now we can hope this echo sends the log to somewhere we can observe later
        killHook = pkgs.writeShellScript "earlyoom-kill-hook" ''
          echo "Process $EARLYOOM_NAME ($EARLYOOM_PID) was killed"
        '';
      };
      systembus-notify.enable = mkForce true;
    };
  };
}

{ lib, config, ... }:
let
  inherit (lib) types mkIf mkOption mkEnableOption;
  profiles = config.cauldron.profiles;

  cfg = config.cauldron.host.feature.security.auditd;
in
{
  options.cauldron.host.feature.security.auditd = {
    enable = mkEnableOption "Enable the audit daemon" // {
      default = (lib.elem "server" profiles);
    };

    autoPrune = {
      enable = mkEnableOption "Enable auto-pruning of audit logs" // {
        default = cfg.enable;
      };

      size = mkOption {
        type = types.int;
        default = 524288000; # ~500 megabytes
        description = "The maximum size of the audit log in bytes";
      };

      dates = mkOption {
        type = types.str;
        default = "daily";
        example = "weekly";
        description = "How often the audit log should be pruned";
      };
    };
  };

  config = mkIf cfg.enable {
    # start as early in the boot process as possible
    boot.kernelParams = ["audit=1"];
    security = {
      auditd.enable = true;

      audit = {
        enable = true;
        backlogLimit = 8192;
        failureMode = "printk";
        rules = [
          "-w /etc/passwd -p wa -k passwd_changes"
          "-w /etc/shadow -p wa -k shadow_changes"
          "-a always,exit -F arch=b64 -S execve -k exec_log"
        ];
      };
    };

    # the audit log can grow quite large, so we _can_ automatically prune it
    systemd = mkIf cfg.autoPrune.enable {
      timers."clean-audit-log" = {
        description = "Periodically clean audit log";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = cfg.autoPrune.dates;
          Persistent = true;
        };
      };

      services."clean-audit-log" = {
        script = ''
          set -eu
          if [[ $(stat -c "%s" /var/log/audit/audit.log) -gt ${toString cfg.autoPrune.size} ]]; then
            echo "Clearing Audit Log";
            rm -rvf /var/log/audit/audit.log;
            echo "Done!"
          fi
        '';

        serviceConfig = {
          Type = "oneshot";
          User = "root";
        };
      };
    };
  };
}

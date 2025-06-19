{ lib, config, ... }:
let
  inherit (lib.modules) mkIf;
  inherit (lib.options) mkOption mkEnableOption;
  inherit (lib.types) int str;
  profiles = config.cauldron.profiles;
  cfg = config.cauldron.security.auditd;
in {
  options.cauldron.security.auditd = {
    enable = mkEnableOption "Enable the audit daemon" // {
      default = (lib.elem "server" profiles);
    };
    autoPrune = {
      enable = mkEnableOption "Enable auto-pruning of audit logs" // {
        default = cfg.enable;
      };
      size = mkOption {
        type = int;
        default = 524288000; # ~500 megabytes
        description = "The maximum size of the audit log in bytes";
      };
      period = mkOption {
        type = str;
        default = "daily";
        example = "weekly";
        description = "How often the audit log should be pruned";
      };
    };
  };
  
  config = mkIf cfg.enable {
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
     # the audit log can grow quite large, so we automatically prune it
    systemd = mkIf cfg.autoPrune.enable {
      timers."clean-audit-log" = {
        description = "Periodically clean audit log";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = cfg.autoPrune.period;
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

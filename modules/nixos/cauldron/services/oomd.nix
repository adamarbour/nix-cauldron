{ config, lib, pkgs, inputs, ... }:
with lib;
let
  cfg = config.make.services.oomd;
in
{
  options.make.services.oomd = {
    enable = mkOption {
      type = types.bool;
      description = "Whether to enable systemd-oomd.";
      default = true;
    };
  };

  config = mkIf cfg.enable {
    systemd = {
      # Systemd OOMd
      # Fedora enables these options by default. See the 10-oomd-* files here:
      # https://src.fedoraproject.org/rpms/systemd/tree/acb90c49c42276b06375a66c73673ac3510255
      oomd = {
        enable = true;
        enableRootSlice = true;
        enableUserSlices = true;
        enableSystemSlice = true;
        extraConfig = {
          "DefaultMemoryPressureDurationSec" = "20s";
        };
      };

      services.nix-daemon.serviceConfig.OOMScoreAdjust = 350;

      tmpfiles.settings."10-oomd-root".w = {
        # Enables storing of the kernel log (including stack trace) into pstore upon a panic or crash.
        "/sys/module/kernel/parameters/crash_kexec_post_notifiers" = {
          age = "-";
          argument = "Y";
        };

        # Enables storing of the kernel log upon a normal shutdown (shutdown, reboot, halt).
        "/sys/module/printk/parameters/always_kmsg_dump" = {
          age = "-";
          argument = "N";
        };
      };
    };
  };
}
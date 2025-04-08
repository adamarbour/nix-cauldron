{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.make.security;
in {
  config = {
    security = {
      # sudo-rs is still a feature-incomplete sudo fork that can and will mess things up
      sudo-rs.enable = mkForce false;
      sudo = {
        enable = true;
        # wheelNeedsPassword = false means wheel group can execute commands without a password
        # so just disable it, it only hurt security, BUT ... see below what commands can be run without password
        wheelNeedsPassword = mkDefault false;
        # Only allow members of the wheel group to execute sudo by setting the executable’s permissions accordingly. This prevents users that are not members of wheel from exploiting vulnerabilities in sudo such as CVE-2021-3156.
        execWheelOnly = true;

        extraConfig = ''
          Defaults lecture = never
          Defaults pwfeedback
          Defaults env_keep += "EDITOR PATH DISPLAY"
          Defaults timestamp_timeout = 300
        '';

        extraRules = [
          {
            groups = [ "wheel" ];
            commands = let
              currentSystem = "/run/current-system/";
              storePath = "/nix/store/";
            in [
              { # why store and not current system?
                # this is because we use switch-to-configuration on rebuild
                command = "${storePath}/*/bin/switch-to-configuration";
                options = [
                  "SETENV"
                  "NOPASSWD"
                ];
              }
              {
                command = "${currentSystem}/sw/bin/nix-store";
                options = [
                  "SETENV"
                  "NOPASSWD"
                ];
              }
              {
                command = "${currentSystem}/sw/bin/nix-env";
                options = [
                  "SETENV"
                  "NOPASSWD"
                ];
              }
              {
                command = "${currentSystem}/sw/bin/nixos-rebuild";
                options = [ "NOPASSWD" ];
              }
              {
                command = "${currentSystem}/sw/bin/darwin-rebuild";
                options = [ "NOPASSWD" ];
              }
              { # let wheel group collect garbage without password
                command = "${currentSystem}/sw/bin/nix-collect-garbage";
                options = [
                  "SETENV"
                  "NOPASSWD"
                ];
              }
              { # let wheel group interact with systemd without password
                command = "${currentSystem}/sw/bin/systemctl";
                options = [ "NOPASSWD" ];
              }
            ];
          }
        ];
      };
    };
  };
}
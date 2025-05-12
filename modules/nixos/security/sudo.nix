{ lib, config, inputs, ... }:
let
  inherit (lib.modules) mkIf mkDefault mkForce;

  cfg = config.cauldron.security;
in {
  config = {
    security.sudo-rs.enable = mkForce false;
    security.sudo = {
      enable = true;
      wheelNeedsPassword = mkDefault false;
      execWheelOnly = true;
      extraConfig = ''
        Defaults lecture = never
        Defaults pwfeedback
        Defaults passwd_timeout = 0
        Defaults env_keep += "EDITOR PATH DISPLAY"
        Defaults timestamp_type = global
        Defaults timestamp_timeout = 300
      '';
      extraRules = [
        {
          groups = [ "wheel" ];

          commands =
            let
              currentSystem = "/run/current-system/";
              storePath = "/nix/store/";
            in
            [
              {
                # why store and not current system?
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
              {
                # let wheel group collect garbage without password
                command = "${currentSystem}/sw/bin/nix-collect-garbage";
                options = [
                  "SETENV"
                  "NOPASSWD"
                ];
              }
              {
                # let wheel group interact with systemd without password
                command = "${currentSystem}/sw/bin/systemctl";
                options = [ "NOPASSWD" ];
              }
            ];
        }
      ];
    };
  };
}
{ lib, pkgs, ... }:
let
  inherit (lib) mkForce mkDefault getExe';
in {
  security = {
    sudo-rs.enable = mkForce false;
    
    sudo = {
      enable = true;
      
      # wheelNeedsPassword = false means wheel group can execute commands without a password
      # so just disable it, it only hurt security, BUT ... see below what commands can be run without password
      wheelNeedsPassword = mkDefault false;

      # only allow members of the wheel group to execute sudo
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

          commands = [
            # allow reboot and shutdown without password
            {
              command = getExe' pkgs.systemd "systemctl";
              options = [ "NOPASSWD" ];
            }
            {
              command = getExe' pkgs.systemd "reboot";
              options = [ "NOPASSWD" ];
            }
            {
              command = getExe' pkgs.systemd "shutdown";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];
    };
  };
}

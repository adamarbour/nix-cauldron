{ lib, config, inputs, ... }:
let

  cfg = config.cauldron.fs;
in {
  # TODO: Fix ... need correct the sizing
  config = {
#    systemd.tmpfiles.settings."10-user-root".D."/nix/var/nix/profiles/per-user/root" = {
#      mode = "755";
#      user = "root";
#      group = "root";
#      age = "-";
#      argument = "-";
#    };
#    
#    fileSystems."/root" = {
#      fsType = "tmpfs";
#      device = "none";
#      options = [
#        "defaults"
#        "size=100M"
#        "mode=0700"
#      ];
#      neededForBoot = true;
#    };
  };
}
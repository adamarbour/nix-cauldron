{ lib, config, ... }:
let
  inherit (lib) mkIf mkDefault mkEnableOption;
  cfg = config.cauldron.services.cloud-init;
in {
  options.cauldron.services.cloud-init = {
    enable = mkEnableOption "Enable cloud-init services.";
  };
  
  config = mkIf (cfg.enable) {
    services.cloud-init = {
      enable = true;
      
      network.enable = true;
      settings.ssh_deletekeys = false;
    } //
    ( lib.genAttrs([
      "btrfs"
      "ext4"
    ])
    (fsName: {
      enable = mkDefault (lib.any (fs: fs.fsType == fsName) (lib.attrValues config.fileSystems));
    })
    );
  };
}

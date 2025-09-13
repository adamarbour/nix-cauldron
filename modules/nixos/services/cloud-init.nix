{ lib, config, ... }:
let
  inherit (lib) types mkIf mkDefault mkEnableOption mkOption;
  cfg = config.cauldron.services.cloud-init;
in {
  options.cauldron.services.cloud-init = {
    enable = mkEnableOption "Enable cloud-init services.";
    network.enable = mkEnableOption "Enable network auto configuration";
    dataSources = mkOption {
      type = types.listOf types.str;
      default = [];
      description = ''
        List of cloud-init datasource backends to enable.
        Examples: [ "Oracle" ], [ "NoCloud" "ConfigDrive"], [ "EC2" ].
      '';
    };
  };
  
  config = mkIf (cfg.enable) {
    services.cloud-init = {
      enable = true;
      
      config = ''
        datasource_list: [ ${lib.concatStringsSep ", " cfg.dataSources} ]
      '';
      network.enable = cfg.network.enable;
      settings.system_info.distro = "nixos";
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

{ lib, config, inputs, ... }:
let
  inherit (lib.modules) mkIf;

  cfg = config.cauldron.environment;
in {
  config = {
    zramSwap = {
      enable = true;
      algorithm = "zstd";
    };

    boot.kernel.sysctl = mkIf config.zramSwap.enable {
      # zram is relatively cheap, prefer swap
      "vm.swappiness" = 180;
      "vm.watermark_boost_factor" = 0;
      "vm.watermark_scale_factor" = 125;
      # zram is in memory, no need to readahead
      "vm.page-cluster" = 0;
    };
  };
}
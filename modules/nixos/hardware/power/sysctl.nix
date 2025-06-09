{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf;
  profiles = config.cauldron.profiles;
in {
  config = mkIf (lib.elem "laptop" profiles) {
    boot.kernel.sysctl = {
    	"vm.dirty_writeback_centisecs" = 6000;
    	"vm.laptop_mode" = 5;
    };
  };
}

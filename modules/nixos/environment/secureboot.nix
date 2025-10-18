{lib, config, ...}:
let
  inherit (lib) mkIf;
  cfg = config.cauldron.host.boot.loader;
  impermanence = config.cauldron.host.disk.impermanence;
in {
  config = mkIf (cfg == "secure" && impermanence.enable) {
    cauldron.host.impermanence.extra.dirs = [ "/var/lib/sbctl" ];
  };
}

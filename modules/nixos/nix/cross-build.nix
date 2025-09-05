{ lib, config, ... }:
let
  inherit (lib) types mkIf mkOption mkEnableOption mkForce;
  cfg = config.cauldron.host.feature.crossbuild;
in {
  options.cauldron.host.feature.crossbuild = {
    enable = mkEnableOption "Enable per-host cross-build support (binfmt + extra platforms)";
    emulatedSystems = mkOption {
      type = types.listOf types.str;
      default = [];
      example = [ "aarch64-linux" "arm7l-linux" ];
      description = ''
        Values for boot.binfmt.emulatedSystems. Enables QEMU user binfmt so this host
        can *run/build* foreign-arch derivations locally.
      '';
    };
    extraPlatforms = mkOption {
      type = types.listOf types.str;
      default = [];
      example = [ "aarch64-linux" ];
      description = ''
        Values for nix.settings.extra-platforms (a.k.a "extra-platforms").
        Tells Nix that this host can build these platforms.
        Use together with emulatedSystems (or real builders).
      '';
    };
  };
  
  config = mkIf cfg.enable {
    boot.binfmt.emulatedSystems = mkForce cfg.emulatedSystems;
    nix.settings."extra-platforms" = mkForce cfg.extraPlatforms;
  };
}

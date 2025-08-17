{ lib, config, sources, ...}:
let
  inherit (lib) mkIf mkDefault;
  profiles = config.cauldron.profiles;
in {
  imports = [
    "${sources.nix-flatpak}/modules/nixos.nix"
  ];
  
  config = mkIf (lib.elem "graphical" profiles) {
    services.flatpak = {
      enable = mkDefault true;
      packages = [
        "com.github.tchx84.Flatseal"
      ];
      update = {
        onActivation = true;
        auto = {
          enable = true;
          onCalendar = "weekly"; # Default value
        };
      };
    };
    environment.sessionVariables.XDG_DATA_DIRS = [ "/var/lib/flatpak/exports/share" ];
  };
}

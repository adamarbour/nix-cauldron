{ lib, config, sources, ...}:
let
  inherit (lib) mkIf mkDefault;
  inherit (lib.cauldron) hasProfile;
  impermanence = config.cauldron.host.disk.impermanence;
in {
  imports = [
    "${sources.nix-flatpak}/modules/nixos.nix"
  ];
  
  config = mkIf (hasProfile config "workstation") {
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
    
    cauldron.host.impermanence.extra = mkIf (impermanence.enable) {
			dirs = [ "/var/lib/flatpak" ];
		};
  };
}

{ lib, config, ... }:
let
  inherit (lib) mkIf;
  profiles = config.cauldron.profiles;
in {

  environment = mkIf (lib.elem "server" profiles) {
    # Print the URL instead on servers
    variables.BROWSER = "echo";
  };
  programs.firefox = mkIf (lib.elem "graphical" profiles) {
    enable = true;
    package = pkgs.unstable.firefox;
    preferences = {
      "sidebar.verticalTabs" = true;
      "extensions.pocket.enabled" = false;
      "toolkit.telemetry.enabled" = false;
      "toolkit.telemetry.unified" = false;
    };
  };
}
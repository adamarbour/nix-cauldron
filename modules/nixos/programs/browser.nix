{ lib, config, ... }:
let
  inherit (lib) mkIf;
  profiles = config.cauldron.profiles;
in {

  environment = mkIf (lib.elem "server" profiles) {
    # Print the URL instead on servers
    variables.BROWSER = "echo";
  };
  
}
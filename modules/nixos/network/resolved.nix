{ lib, ... }:
let
  inherit (lib) mkDefault;
in {
  # systemd DNS resolver daemon
  services.resolved = {
    enable = mkDefault true;
    dnsovertls = "opportunistic";
    dnssec = "true";
    llmnr = "resolve";
  };
}

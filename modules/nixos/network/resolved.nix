{ lib, ... }:
let
  inherit (lib) mkDefault;
in {
  services.resolved = {
    enable = mkDefault true;
    dnsovertls = "opportunistic";
    dnssec = "true";
    llmnr = "resolve";
  };
}

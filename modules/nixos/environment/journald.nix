{ lib, ... }:
let
  inherit (lib) mkDefault;
in {
  services.journald.storage = mkDefault "persistent";
}

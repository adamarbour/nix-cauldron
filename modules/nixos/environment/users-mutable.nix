{ lib, ... }:
let
  inherit (lib) mkDefault;
in {
  users.mutableUsers = mkDefault false;
}

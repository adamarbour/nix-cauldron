{ lib, pkgs, ... }:
let
  inherit (lib) mkDefault;
in {
  environment.shells = with pkgs; [ dash fish ];
  environment.binsh = "${pkgs.dash}/bin/dash";
}

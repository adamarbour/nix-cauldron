{ flake, config, lib, pkgs, inputs, ... }:
with lib;
let
  cfg = config.make;
in {
  imports = [
    # INPUTS
    inputs.disko.nixosModules.default
    inputs.home-manager.nixosModules.home-manager
    inputs.nix-topology.nixosModules.default
    # FLAKE
    flake.modules.shared.nix
    # OPTIONS
    ./boot
    ./environment
    ./networking
    ./platform
    ./secrets
    ./security
    ./services
  ] ++ (with builtins; map (fn: ./${fn}) (filter (fn: fn != "default.nix") (attrNames (readDir ./.))));

  options.make = {
  };

  config = {
    # Don't install the /lib/ld-linux.so.2 stub. This saves one instance of nixpkgs.
    environment.ldso32 = null;
    #  flush the L1 data cache before entering guests
    security.virtualisation.flushL1DataCache = "always";
    # I did read the comment...
    system.stateVersion = "24.05";
  };
}
{ lib, config, inputs, ... }:
let
  cfg = config.cauldron.environment;
in {
  imports = [
    ./console.nix
    ./locale.nix
    ./platform.nix
    ./systemd.nix
    ./xdg-portal.nix
    ./xdg.nix
    ./zram.nix
  ];

  config = {
    # don't install the /lib/ld-linux.so.2 stub. This saves on instance of nixpkgs.
    environment.ldso32 = null;
  };
}
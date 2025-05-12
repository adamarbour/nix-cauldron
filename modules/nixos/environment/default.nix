{ lib, config, inputs, ... }:
let
  cfg = config.cauldron.environment;
in {
  imports = [
  ] ++ (with builtins; map (fn: ./${fn}) (filter (fn: fn != "default.nix") (attrNames (readDir ./.))));

  config = {
    # don't install the /lib/ld-linux.so.2 stub. This saves on instance of nixpkgs.
    environment.ldso32 = null;
  };
}
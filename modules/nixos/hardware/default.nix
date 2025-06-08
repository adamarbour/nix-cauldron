{
  imports = [
    ./cpu
    ./gpu
    ./power
    ./sound
  ] ++ (with builtins; map (fn: ./${fn}) (filter (fn: fn != "default.nix") (attrNames (readDir ./.))));
}

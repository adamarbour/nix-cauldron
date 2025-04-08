{ pkgs }:
pkgs.mkShell {
  # Add build dependencies
  packages = [
    pkgs.nixos-anywhere
    pkgs.nixos-rebuild
  ];

  # Add environment variables
  env = { };

  # Load custom bash code
  shellHook = ''

  '';
}

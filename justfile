
[private]
default:
  @just --list

# check the configuration
[group('dev')]
check:
  colmena apply dry-activate
  
# Update sources
[group('dev')]
update:
  npins update
  
# Upgrade npins
[group('dev')]
upgrade:
  npins upgrade
  npins update --partial

# Show information about the current Nix installation
[group('utils')]
info:
  colmena nix-info
  
# Verify the integrity of the nix store
[group('utils')]
verify *args:
  nix-store --verify {{ args }}

alias fix := repair

# Repair the nix store
[group('utils')]
repair: (verify "--check-contents --repair")

# Clean the nix store
[group('utils')]
clean:
  nix-collect-garbage --delete-older-than 3d
  nix store optimise

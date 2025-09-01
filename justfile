[private]
default:
  @just --list

# Apply configuration specified host (assumes local)
alias switch := apply
[group('dev')]
apply node="self" action="switch":
  @if [ "{{node}}" = "self" ]; then \
    colmena apply-local --sudo --show-trace {{action}}; \
  else \
    colmena apply --on {{node}} --show-trace {{action}}; \
  fi

# Build configuration specified host
[group('dev')]
build node="self":
  @if [ "{{node}}" = "self" ]; then \
    colmena build --show-trace; \
  else \
    colmena build --show-trace --on {{node}}; \
  fi
  
# Start an interactive REPL with the configuration
[group('dev')]
repl:
  colmena repl
  
# Update sources
[group('dev')]
update:
  npins update
  
# Upgrade npins
[group('dev')]
upgrade:
  npins upgrade
  npins update --partial
  
# Verify the integrity of the nix store
[group('utils')]
verify *args:
  nix-store --verify {{ args }} --log-format internal-json -v |& nom --json
  
alias fix := repair

# Repair the nix store
[group('utils')]
repair: (verify "--check-contents --repair")
  
# Clean the nix store
[group('utils')]
clean:
  nix-collect-garbage --delete-older-than 3d --log-format internal-json -v |& nom --json
  nix-store --optimise

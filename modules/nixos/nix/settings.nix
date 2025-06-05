{ pkgs, ... }:
{
  config = {
    nix.settings = {
      # Free up to 20GiB whenever there is less than 5GB left.
      # this setting is in bytes, so we multiply with 1024 by 3
      min-free = 5 * 1024 * 1024 * 1024;
      max-free = 20 * 1024 * 1024 * 1024;
      # automatically optimise symlinks
      auto-optimise-store = true;
      # users or groups which are allowed to do anything with the Nix daemon
      allowed-users = [ "@wheel" "root" ];
      # users or groups which are allowed to manage the nix store
      trusted-users = [ "@wheel" "root" ];
      # we don't want to track the registry, but we do want to allow the usage
      # of the `flake:` references, so we need to enable use-registries
      use-registries = true;
      flake-registry = "";
      # let the system decide the number of max jobs
      max-jobs = "auto";
      # build inside sandboxed environments
      # we only enable this on linux because it servirly breaks on darwin
      sandbox = pkgs.stdenv.hostPlatform.isLinux;
      # supported system features
      system-features = [
        "nixos-test"
        "kvm"
        "recursive-nix"
        "big-parallel"
      ];
      # continue building derivations even if one fails
      # this is important for keeping a nice cache of derivations, usually because I walk away
      # from my PC when building and it would be annoying to deal with nothing saved
      keep-going = true;
      # show more log lines for failed builds, as this happens alot and is useful
      log-lines = 30;
      experimental-features = [
        "flakes"
        "nix-command"
        "ca-derivations"
        "auto-allocate-uids"
        "cgroups"
        "fetch-closure"
        "dynamic-derivations"
        "parse-toml-timestamps"
      ];
      # don't warn me if the current working tree is dirty
      # i don't need the warning because i'm working on it right now
      warn-dirty = false;
      # maximum number of parallel TCP connections used to fetch imports and binary caches, 0 means no limit
      http-connections = 50;
      # whether to accept nix configuration from a flake without prompting
      accept-flake-config = false;
      # for direnv GC roots
      keep-derivations = true;
      keep-outputs = true;
      # use xdg base directories for all the nix things
      use-xdg-base-directories = true;
    };
  };
}

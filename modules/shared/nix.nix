{ lib, pkgs, self, inputs, config, ... }:
let
  inherit (lib.attrsets) filterAttrs mapAttrs;
  inherit (lib.modules) mkForce mkDefault;
  inherit (lib.types) isType;

  flakeInputs = filterAttrs (name: value: (isType "flake" value) && (name != "self")) inputs;
in {
  nix = {
    # pin the registry to avoid downloading and evaluating a new nixpkgs version everytime
    registry = (mapAttrs (_: flake: { inherit flake; }) flakeInputs) // {
      # https://github.com/NixOS/nixpkgs/pull/388090
      nixpkgs = lib.mkForce { flake = inputs.nixpkgs; };
    };
    # Disable nix channels. Use flakes instead.
    channel.enable = mkDefault false;
    # set up garbage collection to run <on the time frame specified per system>, and removing packages after 3 days
    gc = {
      automatic = true;
      options = "--delete-older-than 3d";
      dates = "Mon *-*-* 03:00";
    };
    # automatically optimize /nix/store by removing hard links
    optimise = {
      automatic = true;
      dates = [ "04:00" ];
    };
    # Make builds run with a low priority, keeping the system fast
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
    daemonIOSchedPriority = 7;
    settings = {
      # the defaults to false even if the experimental feature is enabled
      # so we need to enable it here, this is also only available on linux
      # and the option is explicitly removed on darwin so we have to have this here
      use-cgroups = true;
      # set the build dir to /var/tmp to avoid issues on tmpfs
      # https://github.com/NixOS/nixpkgs/issues/293114#issuecomment-2663470083
      build-dir = "/var/tmp";
      # users or groups which are allowed to do anything with the Nix daemon
      allowed-users = [ "root" "@wheel" "@admin" "aarbour" ];
      # users or groups which are allowed to manage the nix store
      trusted-users = [ "root" "@wheel" "@admin" "aarbour" ];
      experimental-features = [
        # enables flakes, needed for this config
        "flakes"
        # enables the nix3 commands, a requirement for flakes
        "nix-command"
        # allow nix to call itself
        "recursive-nix"
        # allow nix to build and use content addressable derivations, these are nice beaccase
        # they prevent rebuilds when changes to the derivation do not result in changes to the derivation's output
        "ca-derivations"
        # Allows Nix to automatically pick UIDs for builds, rather than creating nixbld* user accounts
        # which is BEYOND annoying, which makes this a really nice feature to have
        "auto-allocate-uids"
        # allows Nix to execute builds insnix.ide cgroups
        # remember you must also enable use-cgroups in the nix.conf or settings
        "cgroups"
        # enable the use of the fetchClosure built-in function in the Nix language.
        "fetch-closure"
        # dependencies in derivations on the outputs of derivations that are themselves derivations outputs.
        "dynamic-derivations"
        # allow parsing TOML timestamps via builtins.fromTOML
        "parse-toml-timestamps"
      ]
      ++ lib.optional (lib.versionOlder (lib.versions.majorMinor config.nix.package.version) "2.22") "repl-flake";
      # Fallback quickly if substituters are not available.
      connect-timeout = mkDefault 5;
      # The default at 10 is rarely enough.
      log-lines = mkDefault 25;
      # automatically optimise symlinks
      auto-optimise-store = true;
      # Avoid disk full issues
      max-free = mkDefault (5 * 1024 * 1024 * 1024);
      min-free = mkDefault (20 * 1024 * 1024 * 1024);
      # Avoid copying unnecessary stuff over SSH
      builders-use-substitutes = true;
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
      # don't warn me if the current working tree is dirty
      # i don't need the warning because i'm working on it right now
      warn-dirty = false;
      # maximum number of parallel TCP connections used to fetch imports and binary caches, 0 means no limit
      http-connections = 50;
      # whether to accept nix configuration from a flake without prompting
      # littrally a CVE waiting to happen <https://x.com/puckipedia/status/1693927716326703441>
      accept-flake-config = false;
      # for direnv GC roots
      keep-derivations = true;
      keep-outputs = true;
      # use xdg base directories for all the nix things
      use-xdg-base-directories = true;

      extra-platforms = config.boot.binfmt.emulatedSystems;
    };
  };
}
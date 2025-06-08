{ lib, config, ... }:
let
  inherit (lib) mkDefault;
in {
  # Declarative user management
  services.userborn.enable = true;
  
  # We enable Systemd in the initrd so we can use it to mount the root
  # filesystem this will remove Perl form the activation
  boot.initrd.systemd.enable = mkDefault (!config.boot.swraid.enable && !config.boot.isContainer);
  
  environment = {
    # disable stub-ld, this exists to kill dynamically linked executables, since they cannot work
    # on NixOS, however we know that so we don't need to see the warning
    stub-ld.enable = false;
    # Don't install the /lib/ld-linux.so.2 stub. This saves one instance of nixpkgs.
    ldso32 = null;

    # disable all packages installed by default, i prefer my own packages
    # this list normally includes things like perl
    defaultPackages = lib.mkForce [ ];
  };

  # this can allow us to save some storage space
  fonts.fontDir.decompressFonts = true;
}

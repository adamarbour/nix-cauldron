{ lib, config, ... }:
let
  inherit (lib) mkDefault mkForce;
in {
  # Declarative user management
  services.userborn.enable = false;
  
  # Use Systemd in the initrd by default
  boot.initrd.systemd.enable = mkDefault (!config.boot.swraid.enable && !config.boot.isContainer);
  
  environment = {
    stub-ld.enable = false;
    ldso32 = null;
    defaultPackages = mkForce [ ];
  };
  
  system.etc.overlay.enable = false;
  
  # Save some storage
  fonts.fontDir.decompressFonts = true;
}

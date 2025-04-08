{ config, pkgs, inputs, ...}:
{
  containers.bryaxis = {
    autoStart = true;
    config = { config, pkgs, ... }: {
      # TODO: Use the module....
      services.openssh = {
        enable = true;
        settings.PasswordAuthentication = false;
        settings.PermitRootLogin = "no";
      };
      users.users.builder = {
        isNormalUser = true;
        openssh.authorizedKeys.keyFiles =  with inputs; [ my-keys.outPath ];
      };
      # TODO: Bring in the component ... overrite the extra platforms and trusted users
      nix = {
        settings = {
          trusted-users = [ "root" "builder" ];
          experimental-features = [ "nix-command" "flakes" ];
          # Enable multi-architecture support
          extra-platforms = [ "aarch64-linux" "x86_64-linux" ];
        };
        extraOptions = ''
          builders-use-substitutes = true
        '';
      };
      # For cross-compilation support
      boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

      # Required packages
      environment.systemPackages = with pkgs; [
        git
        qemu
      ];

      # Make sure networking is enabled
      networking.firewall.allowedTCPPorts = [ 22 ];
      networking.hostName = "nixos-builder";
      
      system.stateVersion = "22.11";
    };

    # Bind mounts if needed
    bindMounts = {
      # Optional: Mount a separate storage for the Nix store
      # "/nix-store" = { hostPath = "/path/on/host/nix-store"; isReadOnly = false; };
    };
  };
  # Enable container support
  boot.enableContainers = true;
}
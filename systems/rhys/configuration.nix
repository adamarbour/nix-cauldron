{ pkgs, sources, ... }:
{
  cauldron = {
    profiles = [ "gaming" "desktop" "graphical" "workstation" ];
    
    host = {
      boot = {
        loader = "secure";
        silentBoot = true;
      };
      hardware = {
        cpu = "amd";
        gpu = "amd";
      };
      disk = {
        enable = true;
        encrypt = true;
        rootFs = "btrfs";
        device = "/dev/nvme0n1";
        impermanence = {
          enable = true;
          rootSize = "2G";
        };
      };
      network = {
        wireless.backend = "iwd";
      };
      feature = {
        printing.enable = true;
        bluetooth = true;
        tpm = true;
      };
    };

    secrets = {
      enable = true;
      items = {
        "nebula_ca/ca" = {
          key = "nebula_ca/cert";
          owner = "nebula-cloud"; group = "nebula-cloud"; mode = "0400";
        };
        "nebula/crt" = {
          sopsFile = "trove/hosts/rhys.yaml";
          key = "nebula/crt";
          owner = "nebula-cloud"; group = "nebula-cloud"; mode = "0400";
        };
        "nebula/key" = {
          sopsFile = "trove/hosts/rhys.yaml";
          key = "nebula/key";
          owner = "nebula-cloud"; group = "nebula-cloud"; mode = "0400";
        };
      };
    };
  };

  # Enable the GNOME Desktop Environment.
  services.xserver.desktopManager.gnome.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

}

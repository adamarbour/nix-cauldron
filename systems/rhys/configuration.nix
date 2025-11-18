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
        qemu = true;
      };
    };
    
    services = {
      tailscale.enable = true;
      nebula = {
        enable = true;
        name = "cloud";
        hostname = "rhys";
        cidr = "10.24.13.101/24";
        lighthouses = [ "10.24.13.254" ];
        staticHostMap = {
          "10.24.13.254" = [ "157.137.184.33:4242" "wg.arbour.cloud:4242" ];
        };
        groups = [ "admin" ];
        secrets = {
          ca = "/run/secrets/nebula_ca/ca";
          cert = "/run/secrets/nebula/crt";
          key = "/run/secrets/nebula/key";
        };
        allowAll = true;
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


  services.xserver.desktopManager.gnome.enable = true;
  programs.firefox.enable = true;

}

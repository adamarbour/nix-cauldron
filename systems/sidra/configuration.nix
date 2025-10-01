{ pkgs, ... }:
{ 
  cauldron = {
    profiles = [
      "server"
      "kvm"
    ];
    
    host = {
      boot = {
        loader = "systemd";
      };
      disk = {
        enable = true;
        rootFs = "ext4";
        device = "/dev/sda";
        impermanence = {
          enable = true;
          rootSize = "1G";
        };
        swap.enable = true;
      };
    };
    
    services = {
      cloud-init= {
        enable = true;
        dataSources = [ "Oracle" ];
      };
      nebula = {
        enable = true;
        name = "cloud";
        hostname = "sidra";
        cidr = "10.24.13.254/24";
        isLighthouse = true;
        lighthouses = [];
        staticHostMap = {
          "10.24.13.254" = [ "40.233.13.66:4242" ];
        };
        groups = [ "home" "work" "lab" "nflix" ];
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
        "wg-key" = {
          sopsFile = "trove/wg/sidra.key";
          format = "binary";
        };
        "nebula_ca/ca" = {
          key = "nebula_ca/cert";
          owner = "nebula-cloud"; group = "nebula-cloud"; mode = "0400";
        };
        "nebula_ca/key" = {
          key = "nebula_ca/key";
          owner = "root"; group = "root"; mode = "0400";
        };
        "nebula/crt" = {
          sopsFile = "trove/hosts/sidra.yaml";
          key = "nebula/crt";
          owner = "nebula-cloud"; group = "nebula-cloud"; mode = "0400";
        };
        "nebula/key" = {
          sopsFile = "trove/hosts/sidra.yaml";
          key = "nebula/key";
          owner = "nebula-cloud"; group = "nebula-cloud"; mode = "0400";
        };
      };
    };
  };
}

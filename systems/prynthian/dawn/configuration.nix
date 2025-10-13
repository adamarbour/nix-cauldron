{ pkgs, ... }:
{
  cauldron = {
    profiles = [ "server" ];
    
    host = {
      boot.loader = "systemd";
      hardware.cpu = "intel";
      disk = {
        enable = true;
        rootFs = "ext4";
        device = "/dev/nvme1n1";
        impermanence = {
          enable = true;
          rootSize = "1G";
        };
      };
    };
    
    services = {
      tailscale.enable = true;
      nebula = {
        enable = true;
        name = "cloud";
        hostname = "dawn.prynthian";
        cidr = "10.24.13.6/24";
        lighthouses = [ "10.24.13.254" ];
        staticHostMap = {
          "10.24.13.254" = [ "157.137.184.33:4242" "wg.arbour.cloud:4242" ];
        };
        groups = [ "lab" "prynthian" ];
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
          sopsFile = "trove/hosts/dawn.yaml";
          key = "nebula/crt";
          owner = "nebula-cloud"; group = "nebula-cloud"; mode = "0400";
        };
        "nebula/key" = {
          sopsFile = "trove/hosts/dawn.yaml";
          key = "nebula/key";
          owner = "nebula-cloud"; group = "nebula-cloud"; mode = "0400";
       };
      };
    };
  };
}

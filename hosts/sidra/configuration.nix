{ pkgs, ... }:
{ 
  cauldron = {
    profiles = [
      "server"
      "kvm"
    ];
    host = {
      boot = {
        kernel = pkgs.linuxPackages;
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
    };
  };
}

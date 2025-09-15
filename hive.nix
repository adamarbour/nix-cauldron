{ system ? builtins.currentSystem }:
let
  sources = import ./npins;
in {
  meta = {
    description = "Where all things were Made...";
    nixpkgs = import sources.nixpkgs { };
    specialArgs = { inherit sources; };
  };
  defaults = { lib, name, ... }: {
    imports = [
      ./modules/disks           # Disk templates
      ./modules/nixos
      ./modules/home
      ./users/root.nix
      ./users/aarbour.nix
    ];
    config = {
      networking.hostName = name;
      deployment.targetUser = lib.mkDefault null;
    };
  };
  
  morrigan = {
    imports = [
      ./hosts/morrigan/configuration.nix
      ./hosts/morrigan/hardware.nix
    ];
    config = {
      time.timeZone = "America/Chicago";
      deployment = {
        tags = [ "work" ];
        targetHost = "10.50.16.3";
        targetUser = "aarbour";
      };
    };
  };
  
  cassian = {
    imports = [
      ./hosts/cassian/configuration.nix
      ./hosts/cassian/hardware.nix
    ];
    config = {
      time.timeZone = "America/Chicago";
      deployment = {
        allowLocalDeployment = true;
        targetHost = null;
      };
    };
  };
  
  azriel = {
    imports = [
      ./hosts/azriel/configuration.nix
      ./hosts/azriel/hardware.nix
    ];
    config = {
      time.timeZone = "America/Chicago";
      services.smartd.enable = false;
      deployment = {
        tags = [ "lab" "all" ];
#        targetHost = "10.50.16.3";
        targetUser = "aarbour";
      };
    };
  };
  
  lucien = {
    imports = [
      ./hosts/lucien/configuration.nix
      ./hosts/lucien/hardware.nix
      ./users/steam.nix
    ];
    config = {
      time.timeZone = "America/Chicago";
      deployment = {
        tags = [ "gaming" "all" ];
        targetHost = "100.110.59.111";
        targetUser = "aarbour";
      };
    };
  };
  
  sidra = {
    imports = [
      ./hosts/sidra/configuration.nix
    ];
    config = {
      nixpkgs.hostPlatform = "aarch64-linux";
      deployment = {
        tags = [ "cloud" ];
        targetHost = "40.233.13.66";
        targetUser = "aarbour";
      };
    };
  };
  
  ### PRYNTHIAN - Hosts and containers to support my homelab
  spring = {
    imports = [
      ./hosts/prynthian/spring/configuration.nix
      ./hosts/prynthian/spring/network.nix
    ];
    config = {
      deployment = {
        tags = [ "prynthian" "all" ];
        targetHost = null;
        targetUser = null;
      };
    };
  };
  
  summer = {
    imports = [
      ./hosts/prynthian/summer/configuration.nix
      ./hosts/prynthian/summer/network.nix
    ];
    config = {
      deployment = {
        tags = [ "prynthian" "all" ];
        targetHost = null;
        targetUser = null;
      };
    };
  };
  
  autumn = {
    imports = [
      ./hosts/prynthian/autumn/configuration.nix
      ./hosts/prynthian/autumn/network.nix
    ];
    config = {
      deployment = {
        tags = [ "prynthian" "all" ];
        targetHost = null;
        targetUser = null;
      };
    };
  };
  
  winter = {
    imports = [
      ./hosts/prynthian/winter/configuration.nix
      ./hosts/prynthian/winter/network.nix
    ];
    config = {
      deployment = {
        tags = [ "prynthian" "all" ];
        targetHost = null;
        targetUser = null;
      };
    };
  };
  
  dawn = {
    imports = [
      ./hosts/prynthian/dawn/configuration.nix
      ./hosts/prynthian/dawn/network.nix
    ];
    config = {
      deployment = {
        tags = [ "prynthian" "all" ];
        targetHost = null;
        targetUser = null;
      };
    };
  };
  
  day = {
    imports = [
      ./hosts/prynthian/day/configuration.nix
      ./hosts/prynthian/day/network.nix
    ];
    config = {
      deployment = {
        tags = [ "prynthian" "all" ];
        targetHost = null;
        targetUser = null;
      };
    };
  };
  
  night = {
    imports = [
      ./hosts/prynthian/night/configuration.nix
      ./hosts/prynthian/night/disk.nix
      ./hosts/prynthian/night/network.nix
    ];
    config = {
      deployment = {
        tags = [ "prynthian" "all" ];
        targetHost = null;
        targetUser = null;
      };
    };
  };
  
  ### NFLIX - Hosts and containers supporting nflix.lol
  dlrr = {
    imports = [
      ./hosts/nflix/dlrr/configuration.nix
      ./hosts/nflix/dlrr/network.nix
      ./hosts/nflix/dlrr/disk.nix
    ];
    config = {
      time.timeZone = "America/Chicago";
      deployment = {
        tags = [ "nflix" "all"];
        targetHost = "10.11.12.13";
        targetUser = "aarbour";
      };
    };
  };
}

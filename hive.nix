{ system ? builtins.currentSystem }:
let
  sources = import ./npins;
  nixpkgs = import sources.nixpkgs { };
  lib = nixpkgs.lib.extend (final: prev: {
    cauldron = import ./lib { lib = prev; };
  });
in {
  meta = {
    description = "Where all things were Made...";
    nixpkgs = import sources.nixpkgs { };
    specialArgs = { inherit sources lib; };
  };
  defaults = { lib, name, ... }: {
    imports = [
      ({...}: { _module.args.lib = lib; })  # Custom helpers
      ./homes                               # Home configurations
      ./modules/disks                       # Disk templates
      ./modules/nixos
    ];
    config = {
      networking.hostName = name;
      deployment.targetUser = lib.mkDefault null;
    };
  };
  
  morrigan = {
    imports = [
      ./systems/morrigan/configuration.nix
      ./systems/morrigan/hardware.nix
    ];
    config = {
      time.timeZone = "America/Chicago";
      deployment = {
        tags = [ "work" ];
        allowLocalDeployment = true;
        targetHost = null;
      };
    };
  };
  
  cassian = {
    imports = [
      ./systems/cassian/configuration.nix
      ./systems/cassian/hardware.nix
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
      ./systems/azriel/configuration.nix
      ./systems/azriel/hardware.nix
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
      ./systems/lucien/configuration.nix
      ./systems/lucien/disk.nix
      ./systems/lucien/hardware.nix
    ];
    config = {
      time.timeZone = "America/Chicago";
      deployment = {
        tags = [ "gaming" "all" ];
        targetHost = "10.50.16.31";
        targetUser = "aarbour";
      };
    };
  };
  
  sidra = {
    imports = [
      ./systems/sidra/configuration.nix
    ];
    config = {
      nixpkgs.hostPlatform = "aarch64-linux";
      deployment = {
        buildOnTarget = true;
        tags = [ "cloud" ];
        targetHost = "157.137.184.33"; # public
        targetUser = "aarbour";
      };
    };
  };
  
  ### PRYNTHIAN - Hosts and containers to support my homelab
  spring = {
    imports = [
      ./systems/prynthian/spring/configuration.nix
      ./systems/prynthian/spring/network.nix
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
      ./systems/prynthian/summer/configuration.nix
      ./systems/prynthian/summer/network.nix
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
      ./systems/prynthian/autumn/configuration.nix
      ./systems/prynthian/autumn/network.nix
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
      ./systems/prynthian/winter/configuration.nix
      ./systems/prynthian/winter/network.nix
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
      ./systems/prynthian/dawn/configuration.nix
      ./systems/prynthian/dawn/network.nix
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
      ./systems/prynthian/day/configuration.nix
      ./systems/prynthian/day/network.nix
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
      ./systems/prynthian/night/configuration.nix
      ./systems/prynthian/night/disk.nix
      ./systems/prynthian/night/network.nix
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
      ./systems/nflix/dlrr/configuration.nix
      ./systems/nflix/dlrr/network.nix
      ./systems/nflix/dlrr/vpn.nix
    ];
    config = {
      cauldron.profiles = [ "server" "kvm" ];
      deployment = {
        tags = [ "nflix" "all"];
        targetHost = "82.118.230.103";
        targetUser = "aarbour";
      };
    };
  };
}

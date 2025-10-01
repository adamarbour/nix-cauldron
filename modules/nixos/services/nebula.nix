{ lib, config, ... }:
let
  inherit (lib) types mkIf mkOption mkEnableOption optionalAttrs;
  cfg = config.cauldron.services.nebula;
  
  stripMask = ip: let
    parts = lib.splitString "/" ip;
  in builtins.head parts;
    
  netName = cfg.name;
  isLH = cfg.isLighthouse;
  listenPort = if cfg.listenPort != null then cfg.listenPort
    else if isLH then 4242 else 0;
in {
  options.cauldron.services.nebula = {
    enable = mkEnableOption "Enable Nebula overlay networking";
    name = mkOption {
      type = types.str;
      default = "cluster";
      description = "Overlay network name (becomes nebula@<name>).";
    };
    hostname = mkOption {
      type = types.str;
      description = "Logical Nebula node name (metadata only, nice for ACLs later).";
    };
    cidr = mkOption {
      type = types.str;
      example = "10.13.0.1/24";
      description = "Node's Nebula overlay address with mask";
    };
    isLighthouse = mkOption {
      type = types.bool;
      default = false;
      description = "Whether this node serves as a lighthouse.";
    };
    lighthouses = mkOption {
      type = types.listOf types.str;
      default = [];
      example = [ "10.13.0.1" ];
      description = "Nebula IPs (no CIDR) of lighthouses in contact.";
    };
    staticHostMap = mkOption {
      type = types.attrsOf (types.listOf types.str);
      default = {};
      example = { "10.13.0.1" = [ "203.0.113.10:4242" ]; };
      description = "Map Nebula IP (no CIDR) -> [\"public.ip:port\:] entries.";
    };
    groups = mkOption {
      type = types.listOf types.str;
      default = [];
      example = [ "home" "work" ];
      description = "Nebula metadata groups for firewall rules.";
    };
    mtu = mkOption {
      type = types.int;
      default = 1300;
      description = "TUN MTU. 1300 playes nice with most NATs.";
    };
    listenPort = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = "UDP listen port. Null is sensible default based on role.";
    };
    allowAll = mkOption {
      type = types.bool;
      default = true; # TODO: tighten later don't default to true;
      description = "Allow all overlay traffic (inbound/outbound).";
    };
    punch = mkOption {
      type = types.bool;
      default = true;
      description = "Enable NAT hole punching (punch/respond).";
    };
    secrets = {
      ca = mkOption { type = types.nullOr types.path; default = null; description = "Path to ca.crt"; };
      cert = mkOption { type = types.nullOr types.path; default = null; description = "Path to host certificate"; };
      key = mkOption { type = types.nullOr types.path; default = null; description = "Path to host private key"; };
    };
    extraSettings = mkOption {
      type = types.attrs;
      default = {};
      description = "Raw Nebula settings to merge into generated config.";
    };
    firewall = {
      inbound = mkOption {
        type = types.listOf types.attrs;
        default = [];
        description = "Nebula inbound rule list (ignored if allowAll=true).";
      };
      outbound = mkOption {
        type = types.listOf types.attrs;
        default = [];
        description = "Nebula outbound rule list (ignored if allowAll=true).";
      };
    };
    
  };

  config = mkIf cfg.enable {
    services.nebula.networks.${netName} = {
      ca = cfg.secrets.ca;
      cert = cfg.secrets.cert;
      key = cfg.secrets.key;
      
      isLighthouse = isLH;
      lighthouses = cfg.lighthouses;
      staticHostMap = cfg.staticHostMap;
      
      listen.port = listenPort;
      
      firewall = if cfg.allowAll then {
        inbound  = [ { port = "any"; proto = "any"; host = "any"; } ];
        outbound = [ { port = "any"; proto = "any"; host = "any"; } ];
      } else {
        inbound = cfg.firewall.inbound;
        outbound = cfg.firewall.outbound;
      };
      
      settings = lib.recursiveUpdate {
        pki = {}; # upstream fills paths
        lighthouse = optionalAttrs isLH { interval = 60; };
        punhcy = { punch = cfg.punch; respond = cfg.punch; };
        tun = {
          cidr = cfg.cidr;
          mtu = cfg.mtu;
        };
        metadata = {
          name = cfg.hostname;
          groups = cfg.groups;
        };
      } cfg.extraSettings;
    };
  };
}

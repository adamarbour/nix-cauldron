{ lib, pkgs, config, sources, ... }:
let
  inherit (lib) unique mkIf mapAttrs' mapAttrsToList nameValuePair optionalAttrs;
  
  impermanence = config.cauldron.host.disk.impermanence;
  persistRoot = if (impermanence.enable) then config.cauldron.host.impermanence.root else "";
  
  cfg = config.cauldron.secrets;
  
  # Helper to render sops.secrets entries
  renderSecret = name: opts:
    nameValuePair name (lib.filterAttrs (_: v: v != null) ({
      # fall back to the module's default file if not set per-item
      sopsFile = opts.sopsFile or cfg.defaultFile;
      owner    = opts.owner;
      group    = opts.group;
      mode     = opts.mode;
      format   = opts.format;
      restartUnits = opts.restartUnits;
    } // optionalAttrs (opts.key != null)  { inherit (opts) key; }
      // optionalAttrs (opts.path != null) { inherit (opts) path; }));
  
  # Build tmpfiles.d rules for any custom path; ensures parent dirs exist with correct ownership.
  customPaths = lib.filter (v: v.path != null) (mapAttrsToList (n: v: v // { _name = n; }) cfg.items);
  
  mkTmpfilesRule = v:
    let dir = builtins.dirOf v.path; in
    # Use 0750 by default; adjust if you need broader read access
    "d ${dir} 0750 ${v.owner} ${v.group} - -";
in {
  imports = [ (sources.sops-nix + "/modules/sops") ];
  
  config = mkIf cfg.enable {
    sops = {
      defaultSopsFile = cfg.defaultFile;
      age.sshKeyPaths = [ "${persistRoot}/etc/ssh/ssh_host_ed25519_key" ];
    };
    
    # Materialize sops.secrets from our high-level items
    sops.secrets = mapAttrs' renderSecret cfg.items;
    
    systemd.tmpfiles.rules = unique (map mkTmpfilesRule customPaths);
    
    environment.systemPackages = with pkgs; [
      	age
      	sops
      	ssh-to-age
    ];
  };
}

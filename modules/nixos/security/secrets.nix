{ lib, pkgs, config, sources, ... }:
let
  inherit (lib) unique mkIf mapAttrs' mapAttrsToList nameValuePair optionalAttrs hasPrefix;
  
  impermanence = config.cauldron.host.disk.impermanence;
  persistRoot = if (impermanence.enable) then config.cauldron.host.impermanence.root else "";
  
  secretsRepo = sources.secrets;
  cfg = config.cauldron.secrets;
  
  # Accept either a path or a relative string; resolve to a path under cfg.root
  resolvePath =
    p:
      if p == null then null else
      if builtins.isPath p then p else
      let s = toString p; in
        if hasPrefix "/" s
        then builtins.toPath s
        else builtins.toPath "${cfg.root}/${s}";
  
  # Helper to render sops.secrets entries
  renderSecret = name: opts:
    let resolved = resolvePath (opts.sopsFile or cfg.defaultFile); in
    nameValuePair name (lib.filterAttrs (_: v: v != null) ({
      # fall back to the module's default file if not set per-item
      sopsFile = resolved;
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

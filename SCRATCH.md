# SCRATCH
Just some notes...

1. Disk prep
```
sudo disko --mode destroy,format,mount ./disks/{{file}} --arg device '"/dev/{{device}}"'
```

2. Get hardware configuration (in stdout)
```
sudo nixos-generate-config --root /mnt --show-hardware-config --no-filesystems
```
3a. Remote deployment
```
nixos-anywhere --store-paths $(nix-build -E '(import ./hive-anywhere.nix).$HOST.disko-script') $(nix-build -E '(import ./hive-anywhere.nix).$HOST.nixos-system') root@$HOST
```

3b. Local Deploy
```
# LOCAL INSTALL (initial)
colmena build --on {{HOST}} --no-build-on-target
sudo nixos-install --system /nix/store/myclosure <-- output from above
```

## Goals
1. Centralize the setup, management and rollout of my fleet of servers and devices that support various use cases in my personal and professional environments
2. Capture and version incremental improvements towards minimal management and seamless reproducibility
3. Improve my overall productivity, daily workflows in a clean aesthetically pleasing environment
    

## Tasks
1. Get streaming setup for configuration changes...
2. Get nvim setup and ready for usage as primary ide
3. Get desktop setup for daily usage
4. Get notes environment setup for daily usage
5. Get homelab setup
6. Get kubernetes setup
7. Start deploying enterprise software
8. Get gaming desktop setup
9. Get couch gaming system setup
10. Get download server(s) setup
11. Get primary cloud device setup

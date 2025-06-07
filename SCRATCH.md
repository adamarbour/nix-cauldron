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

3. Deploy
```
# LOCAL
colmena build --on {{HOST}} --no-build-on-target
sudo nixos-install --system /nix/store/myclosure <-- output from above
```

## Goals
1. Centralize the setup, management and rollout of my fleet of servers and devices that support various use cases in my personal and professional environments
2. Capture and version incremental improvements towards minimal management and seamless reproducibility
3. Improve my overall productivity, daily workflows in a clean aesthetically pleasing environment

## Roadmap of TODOs
TBD

## Backlog of TODOs
### Hosts
    - Cassian - My primary device
    - Azriel - Reporting dashboard mounted to the wall
    - Velaris - Gaming desktop
        - Amren - Windows gaming via Sunshine/Moonlight
    - Courts (Prynthian) - My homelab cluster
        - Spring
        - Summer
        - Autumn
        - Winter
        - Dawn
        - Day
        - Night
            - Hewn - NAS
    - Mountain - Cloud seedbox/collector
    
### Stages
1. Core
    - Boot modules supporting Systemd, Grub and Secure Boot
    - Disk & Filesystem utilities
    - Secrets management
    - Networking, SSH & Tailscale
    - Security/Hardening & Auditd
2. Graphical/ Rice
    - Desktop Experience
    - Flatpak
    - Gaming
    - Theme & Colors
    - Obsidian
    - Browser
3. Monitoring & Backup
    - Exporters - Core metrics
    - Prometheus capture
    - Grafana dashboard
4. Development
    - IDE
    - 
5. Automation


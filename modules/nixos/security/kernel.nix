{ lib, config, ... }:
let
  inherit (lib) mkIf mkDefault concatLists optionals;
  profiles = config.cauldron.profiles;
  cfg = config.cauldron.host.feature;
in {
  config = mkIf (lib.elem "server" profiles || lib.elem "workstation" profiles) {
    services.jitterentropy-rngd.enable = mkDefault (!config.boot.isContainer);
    security = {
      protectKernelImage = true;
      lockKernelModules = false; # breaks virtd, wireguard and iptables

      # force-enable the Page Table Isolation (PTI) Linux kernel feature
      forcePageTableIsolation = true;

      # User namespaces are required for sandboxing.
      # this means you cannot set `"user.max_user_namespaces" = 0;` in sysctl
      allowUserNamespaces = true;

      # Disable unprivileged user namespaces, unless containers are enabled
      unprivilegedUsernsClone = false;

      allowSimultaneousMultithreading = true;
    };
    boot = {
      kernelModules = [ "jitterentropy_rng" ];
      loader.systemd-boot.editor = mkDefault false;
      kernel = {
        sysctl = {
          # Prevent boot console log leaking information
          "kernel.printk" = "3 3 3 3";
          "fs.suid_dumpable" = 0;
          # prevent pointer leaks
          "kernel.kptr_restrict" = 2;
          # restrict kernel log to CAP_SYSLOG capability
          "kernel.dmesg_restrict" = 1;
          # Note: certian container runtimes or browser sandboxes might rely on the following
          # restrict eBPF to the CAP_BPF capability
          "kernel.unprivileged_bpf_disabled" = 1;
          # should be enabled along with bpf above
          "net.core.bpf_jit_harden" = 2;
          # restrict loading TTY line disciplines to the CAP_SYS_MODULE
          "dev.tty.ldisk_autoload" = 0;
          # prevent exploit of use-after-free flaws
          "vm.unprivileged_userfaultfd" = 0;
          # kexec is used to boot another kernel during runtime and can be abused
          "kernel.kexec_load_disabled" = 1;
          # Kernel self-protection
          # SysRq exposes a lot of potentially dangerous debugging functionality to unprivileged users
          # 4 makes it so a user can only use the secure attention key. A value of 0 would disable completely
          "kernel.sysrq" = 4;
          # disable unprivileged user namespaces, Note: Docker, NH, and other apps may need this
          # "kernel.unprivileged_userns_clone" = 0; # commented out because it makes NH and other programs fail
          # restrict all usage of performance events to the CAP_PERFMON capability
          "kernel.perf_event_paranoid" = 3;
# TODO: Move to enhanced module or enable option...          
#          # Network
#          # protect against SYN flood attacks (denial of service attack)
#          "net.ipv4.tcp_syncookies" = 1;
#          # protection against TIME-WAIT assassination
#          "net.ipv4.tcp_rfc1337" = 1;
#          # enable source validation of packets received (prevents IP spoofing)
#          "net.ipv4.conf.default.rp_filter" = 1;
#          "net.ipv4.conf.all.rp_filter" = 1;
#          "net.ipv4.conf.all.accept_redirects" = 0;
#          "net.ipv4.conf.default.accept_redirects" = 0;
#          "net.ipv4.conf.all.secure_redirects" = 0;
#          "net.ipv4.conf.default.secure_redirects" = 0;
#          # Protect against IP spoofing
#          "net.ipv6.conf.all.accept_redirects" = 0;
#          "net.ipv6.conf.default.accept_redirects" = 0;
#          "net.ipv4.conf.all.send_redirects" = 0;
#          "net.ipv4.conf.default.send_redirects" = 0;
#          # prevent man-in-the-middle attacks
#          "net.ipv4.icmp_echo_ignore_all" = 1;
#          # ignore ICMP request, helps avoid Smurf attacks
#          "net.ipv4.conf.all.forwarding" = 0;
#          "net.ipv4.conf.default.accept_source_route" = 0;
#          "net.ipv4.conf.all.accept_source_route" = 0;
#          "net.ipv6.conf.all.accept_source_route" = 0;
#          "net.ipv6.conf.default.accept_source_route" = 0;
#          # Reverse path filtering causes the kernel to do source validation of
#          "net.ipv6.conf.all.forwarding" = 0;
#          "net.ipv6.conf.all.accept_ra" = 0;
#          "net.ipv6.conf.default.accept_ra" = 0;
          
          ## TCP hardening
          # Prevent bogus ICMP errors from filling up logs.
          "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
          # TCP optimization
          # TCP Fast Open is a TCP extension that reduces network latency by packing
          # data in the sender’s initial TCP SYN. Setting 3 = enable TCP Fast Open for
          # both incoming and outgoing connections:
          "net.ipv4.tcp_fastopen" = 3;
          # Bufferbloat mitigations + slight improvement in throughput & latency
          "net.ipv4.tcp_congestion_control" = "bbr";
          "net.core.default_qdisc" = "cake";

          # Disable TCP SACK
          "net.ipv4.tcp_sack" = 0;
          "net.ipv4.tcp_dsack" = 0;
          "net.ipv4.tcp_fack" = 0;
          
          # Userspace
          # restrict usage of ptrace
          "kernel.yama.ptrace_scope" = 2;
          # ASLR memory protection (64-bit systems)
          "vm.mmap_rnd_bits" = 32;
          "vm.mmap_rnd_compat_bits" = 16;
          # only permit symlinks to be followed when outside of a world-writable sticky directory
          "fs.protected_symlinks" = 1;
          "fs.protected_hardlinks" = 1;
          # Prevent creating files in potentially attacker-controlled environments
          "fs.protected_fifos" = 2;
          "fs.protected_regular" = 2;
          # Randomize memory
          "kernel.randomize_va_space" = 2;
          # Exec Shield (Stack protection)
          "kernel.exec-shield" = 1;
        };
      };
      kernelParams = [
        # ignore access time (atime) updates on files, except when they coincide with updates to the ctime or mtime
        "rootflags=noatime"
        
        # make it harder to influence slab cache layout
        "slab_nomerge"
      
        # enables zeroing of memory during allocation and free time
        # helps mitigate use-after-free vulnerabilaties
        "init_on_alloc=1"
        "init_on_free=1"
        
        # randomizes page allocator freelist, improving security by
        # making page allocations less predictable
        "page_alloc.shuffle=1"
        
        # enables Kernel Page Table Isolation, which mitigates Meltdown and
        # prevents some KASLR bypasses
        "pti=on"
        
        # randomizes the kernel stack offset on each syscall
        # making attacks that rely on a deterministic stack layout difficult
        "randomize_kstack_offset=on"
        
        # disables vsyscalls, they've been replaced with vDSO
        "vsyscall=none"
      
        # disables debugfs, which exposes sensitive info about the kernel
        "debugfs=off"

        # certain exploits cause an "oops", this makes the kernel panic if an "oops" occurs
        "oops=panic"

        # only alows kernel modules that have been signed with a valid key to be loaded
        # making it harder to load malicious kernel modules
        # can make VirtualBox or Nvidia drivers unusable
        "module.sig_enforce=1"

        # prevents user space code excalation
        "lockdown=confidentiality"

        # enable buddy allocator free poisoning
        "page_poison=on"

        # for debugging kernel-level slab issues
        "slub_debug=FZP"

        # disable sysrq keys. sysrq is seful for debugging, but also insecure
        "sysrq_always_enabled=0" # 0 | 1 # 0 means disabled

        # linux security modules
        "lsm=landlock,lockdown,yama,integrity,apparmor,bpf,tomoyo,selinux"

        # prevent the kernel from blanking plymouth out of the fb
        "fbcon=nodefer"

        # Apply relevant CPU exploit mitigations, and disable symmetric 
        # multithreading. May harm performance. See overrides.
        "mitigations=auto,nosmt"
      ];
      blacklistedKernelModules = concatLists [ 
        # Obscure network protocols
        [
          "dccp" # Datagram Congestion Control Protocol
          "sctp" # Stream Control Transmission Protocol
          "rds" # Reliable Datagram Sockets
          "tipc" # Transparent Inter-Process Communication
          "n-hdlc" # High-level Data Link Control
          "netrom" # NetRom
          "x25" # X.25
          "ax25" # Amateur X.25
          "rose" # ROSE
          "decnet" # DECnet
          "econet" # Econet
          "af_802154" # IEEE 802.15.4
          "ipx" # Internetwork Packet Exchange
          "appletalk" # Appletalk
          "psnap" # SubnetworkAccess Protocol
          "p8022" # IEEE 802.3
          "p8023" # Novell raw IEEE 802.3
          "can" # Controller Area Network
          "atm" # ATM
        ]
        # Old or rare or insufficiently audited filesystems
        [
          "adfs" # Active Directory Federation Services
          "affs" # Amiga Fast File System
          "befs" # "Be File System"
          "bfs" # BFS, used by SCO UnixWare OS for the /stand slice
          "cramfs" # compressed ROM/RAM file system
          "cifs" # smb (Common Internet File System)
          "efs" # Extent File System
          "erofs" # Enhanced Read-Only File System
          "exofs" # EXtended Object File System
          "freevxfs" # Veritas filesystem driver
          "f2fs" # Flash-Friendly File System
          "vivid" # Virtual Video Test Driver (unnecessary)
          "gfs2" # Global File System 2
          "hpfs" # High Performance File System (used by OS/2)
          "hfs" # Hierarchical File System (Macintosh)
          "hfsplus" # " same as above, but with extended attributes
          "jffs2" # Journalling Flash File System (v2)
          "jfs" # Journaled File System - only useful for VMWare sessions
          "ksmbd" # SMB3 Kernel Server
          "minix" # minix fs - used by the minix OS
          "nfsv3" # " (v3)
          "nfsv4" # Network File System (v4)
          "nfs" # Network File System
          "nilfs2" # New Implementation of a Log-structured File System
          "omfs" # Optimized MPEG Filesystem
          "qnx4" # extent-based file system used by the QNX4 and QNX6 OSes
          "qnx6" # ^
          "squashfs" # compressed read-only file system (used by live CDs)
          "sysv" # implements all of Xenix FS, SystemV/386 FS and Coherent FS.
          "udf" # https://docs.kernel.org/5.15/filesystems/udf.html
        ]
        # Disable pc speakers, does anyone actually use these
        [
          "pcspkr"
          "snd_pcsp"
        ]
        
        (optionals (!cfg.thunderbolt) [
          "firewire-core"
          "thunderbolt"
        ])
        
        (optionals (!cfg.bluetooth) [
          "bluetooth"
          "btusb" # bluetooth dongles
        ])
      ];
    };
  };
}

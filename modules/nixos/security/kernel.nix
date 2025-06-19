{ lib, config, ... }:
let
  inherit (lib) mkDefault concatLists;
in {
  config = {
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
          # The Magic SysRq key is a key combo that allows users connected to the
          # system console of a Linux kernel to perform some low-level commands.
          # Disable it, since we don't need it, and is a potential security concern.
          "kernel.sysrq" = 0;

          # Restrict ptrace() usage to processes with a pre-defined relationship
          # (e.g., parent/child)
          "kernel.yama.ptrace_scope" = 3;

          # Hide kptrs even for processes with CAP_SYSLOG
          "kernel.kptr_restrict" = 2;

          # Disable bpf() JIT (to eliminate spray attacks)
          "net.core.bpf_jit_enable" = false;

          # Disable ftrace debugging
          "kernel.ftrace_enabled" = false;

          # Avoid kernel memory address exposures via dmesg (this value can also be set by CONFIG_SECURITY_DMESG_RESTRICT).
          "kernel.dmesg_restrict" = 1;

          # Prevent unintentional fifo writes
          "fs.protected_fifos" = 2;

          # Prevent unintended writes to already-created files
          "fs.protected_regular" = 2;

          # Disable SUID binary dump
          "fs.suid_dumpable" = 0;

          # Prevent unprivileged users from creating hard or symbolic links to files
          "fs.protected_hardlinks" = 1;
          "fs.protected_symlinks" = 1;

          # Disallow profiling at all levels without CAP_SYS_ADMIN
          "kernel.perf_event_paranoid" = 3;

          # Require CAP_BPF to use bpf
          "kernel.unprivileged_bpf_disabled" = 1;

          # Prevent boot console log leaking information
          "kernel.printk" = "3 3 3 3";

          # Restrict loading TTY line disaciplines to the CAP_SYS_MODULE capablitiy to
          # prevent unprvileged attackers from loading vulnrable line disaciplines
          "dev.tty.ldisc_autoload" = 0;

          # Kexec allows replacing the current running kernel. There may be an edge case where
          # you wish to boot into a different kernel, but I do not require kexec. Disabling it
          # patches a potential security hole in our system.
          "kernel.kexec_load_disabled" = 1;

          # Disable TIOCSTI ioctl, which allows a user to insert characters into the input queue of a terminal
          # this has been known for a long time to be used in privilege escalation attacks
          "dev.tty.legacy_tiocsti" = 0;
          
          "kernel.core_pattern" = "|/bin/false";
          "vm.mmap_rnd_bits" = "32";
          "vm.mmap_rnd_compat_bits" = "16";
          "vm.unprivileged_userfaultfd" = 0;
          
          # enable ASLR
          # turn on protection and randomize stack, vdso page and mmap + randomize brk base address
          "kernel.randomize_va_space" = 2;
          
          # restrict perf subsystem usage (activity) further
          "kernel.perf_cpu_time_max_percent" = 1;
          "kernel.perf_event_max_sample_rate" = 1;
          
          # do not allow mmap in lower addresses
          "vm.mmap_min_addr" = "65536";
        };
      };
      kernelParams = [
        # make stack-based attacks on the kernel harder
        "randomize_kstack_offset=on"

        # controls the behavior of vsyscalls. this has been defaulted to none back in 2016 - break really old binaries for security
        "vsyscall=none"

        # reduce most of the exposure of a heap attack to a single cache
        "slab_nomerge"

        # Disable debugfs which exposes sensitive kernel data
        "debugfs=off"

        # Sometimes certain kernel exploits will cause what is called an "oops" which is a kernel panic
        # that is recoverable. This will make it unrecoverable, and therefore safe to those attacks
        "oops=panic"

        # only allow signed modules
        "module.sig_enforce=1"

        # blocks access to all kernel memory, even preventing administrators from being able to inspect and probe the kernel
        "lockdown=confidentiality"

        # enable buddy allocator free poisoning
        "page_poison=on"

        # performance improvement for direct-mapped memory-side-cache utilization, reduces the predictability of page allocations
        "page_alloc.shuffle=1"

        # for debugging kernel-level slab issues
        "slub_debug=FZP"

        # disable sysrq keys. sysrq is seful for debugging, but also insecure
        "sysrq_always_enabled=0" # 0 | 1 # 0 means disabled

        # ignore access time (atime) updates on files, except when they coincide with updates to the ctime or mtime
        "rootflags=noatime"

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
      ];
    };
  };
}

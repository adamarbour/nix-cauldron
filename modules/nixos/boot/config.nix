{ lib, pkgs, config, ...}:
let
  inherit (lib.modules) mkIf mkForce mkMerge mkDefault mkOverride;
  inherit (lib.lists) optionals;
  inherit (lib.options) mkOption mkEnableOption literalExpression;
  inherit (lib.types) str raw listOf package;
  
  cfg = config.cauldron.host;
in {
  
  options.cauldron.host = {
    kernel = mkOption {
      type = raw;
      default = pkgs.linuxPackages_latest;
      defaultText = "pkgs.linuxPackages_latest";
      description = "The kernel to use for the system.";
    };
    enableKernelTweaks = mkEnableOption "security and performance related kernel parameters";
    tmpOnTmpfs = mkEnableOption "`/tmp` living on tmpfs. false means it will be cleared manually on each reboot"
      // { default = true; };
    
    boot = {
      silentBoot = mkEnableOption ''
        almost entirely silent boot process through `quiet` kernel parameter
      '';
      
      extraModulePackages = mkOption {
        type = listOf package;
        default = [ ];
        example = literalExpression ''with config.boot.kernelPackages; [acpi_call]'';
        description = "Extra kernel modules to be loaded.";
      };
      extraModprobeConfig = mkOption {
        type = str;
        default = ''options hid_apple fnmode=1'';
        description = "Extra modprobe config that will be passed to system modprobe config.";
      };
      
      initrd = {
        enableTweaks = mkEnableOption "quality of life tweaks for the initrd stage";
        optimizeCompressor = mkEnableOption ''
          initrd compression algorithm optimizations for size.
          Enabling this option will force initrd to use zstd (default) with
          level 19 and -T0 (STDIN). This will reduce thee initrd size greatly
          at the cost of compression speed.
          Not recommended for low-end hardware.
        '';
      };
    };
  };

  config = {
    boot = {
      consoleLogLevel = 3;
      kernelPackages = mkOverride 500 cfg.kernel;
      
      extraModulePackages = mkDefault cfg.boot.extraModulePackages;
      extraModprobeConfig = mkDefault cfg.boot.extraModprobeConfig;
      
      swraid.enable = mkDefault false;
      
      loader = {
        # if set to 0, space needs to be held to get the boot menu to appear
        timeout = mkForce 2;
        # copy boot files to /boot so that /nix/store is not required to boot
        # it takes up more space but it makes my messups a bit safer
        generationsDir.copyKernels = true;
        # we need to allow installation to modify EFI variables
        efi.canTouchEfiVariables = true;
      };
      
      # increase the map count, this is important for applications that require a lot of memory mappings
      # such as games and emulators
      kernel.sysctl."vm.max_map_count" = 2147483642;
      
      # if you have a lack of ram, you should avoid tmpfs to prevent hangups while compiling
      tmp = {
        # /tmp on tmpfs, lets it live on your ram
        useTmpfs = cfg.tmpOnTmpfs;

        # If not using tmpfs, which is naturally purged on reboot, we must clean
        # we have to clean /tmp
        cleanOnBoot = mkDefault (!config.boot.tmp.useTmpfs);

        # enable huge pages on tmpfs for better performance
        tmpfsHugeMemoryPages = "within_size";
      };
      
      initrd = mkMerge [
        (mkIf config.systemd.enableEmergencyMode {
          # Given that our systems are headless, emergency mode is useless.
          # We prefer the system to attempt to continue booting so
          # that we can hopefully still access it remotely.
          systemd.suppressedUnits = [
            "emergency.service"
            "emergency.target"
          ];
        })
        
        (mkIf cfg.boot.initrd.enableTweaks {
          # Verbosity of the initrd
          # disabling verbosity removes only the mandatory messages generated by the NixOS
          verbose = false;
          kernelModules = [
            "nvme"
            "xhci_pci"
            "ahci"
            "btrfs"
            "sd_mod"
            "dm_mod"
          ];
          availableKernelModules = [
            "vmd"
            "usbhid"
            "sd_mod"
            "sr_mod"
            "dm_mod"
            "uas"
            "usb_storage"
            "rtsx_usb_sdmmc"
            "rtsx_pci_sdmmc" # Realtek SD card interface (btw i hate realtek)
            "ata_piix"
            "virtio_pci"
            "virtio_scsi"
            "ehci_pci"
          ];
        })
        
        (mkIf cfg.boot.initrd.optimizeCompressor {
          compressor = "zstd";
          compressorArgs = [
            "-19"
            "-T0"
          ];
        })
      ];
      
      kernelParams = [
      	"nowatchdog"
      	"nmi_watchdog=0"
      	"usbcore.autosuspend=5"
      ]
      ++ optionals cfg.enableKernelTweaks [
        # https://en.wikipedia.org/wiki/Kernel_page-table_isolation
        # auto means kernel will automatically decide the pti state
        "pti=auto" # on || off
        
        # enable IOMMU for devices used in passthrough and provide better host performance
        "iommu=pt"
        
        # allow systemd to set and save the backlight state
        "acpi_backlight=native"
        
        # prevent the kernel from blanking plymouth out of the fb
        "fbcon=nodefer"
        
        # disable boot logo
        "logo.nologo"

        # disable the cursor in vt to get a black screen during intermissions
        "vt.global_cursor_default=0"
      ]
      ++ optionals cfg.boot.silentBoot [
        "quiet"
        "loglevel=3"
        "udev.log_level=3"
        "rd.udev.log_level=3"
        "systemd.show_status=auto"
        "rd.systemd.show_status=auto"
      ];
    };
  };
}

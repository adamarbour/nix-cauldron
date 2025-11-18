{ lib, pkgs, config, ...}:
let
    inherit (lib) mkIf mkDefault;
    cfg = config.cauldron.host.feature;
in {
    options.cauldron.host.feature.qemu = mkOption {
        type = types.bool;
        default = false;
        description = "Libvirt-based virtualization stack (KVM/QEMU).";
    };

    config = mkIf cfg.qemu {
        virtualisation.libvirtd = {
            enable = true;

            onBoot = mkDefault "ignore";
            onShutdown = mkDefault "shutdown";

            qemu = {
                package = mkDefault pkgs.qemu_kvm;
                runAsRoot = mkDefault false;

                swtpm.enable = true;
                ovmf.packages = [ pkgs.OVMFFull.fd ];
            };
            extraConfig = ''
                unix_sock_group = "libvirtd"
            '';
        };

        virtualisation.spiceUSBRedirection.enable = true;
        
        cauldron.packages = {
			inherit (pkgs) gnome-boxes dnsmasq dmidecode phodav virtio-win spice-gtk virt-manager;
		};
    };
}
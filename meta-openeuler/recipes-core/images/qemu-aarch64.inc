# image configuration for aarch64
require qemu.inc

# qemuboot options
QB_SYSTEM_NAME = "qemu-system-aarch64"
# get the first item from IMAGE_FSTYPES
QB_DEFAULT_FSTYPE = "${@d.getVar('IMAGE_FSTYPES').split(' ')[0]}"
QB_MACHINE = "-machine virt,gic-version=3"
QB_CPU = "-cpu cortex-a53"
QB_SMP = "-smp 4"
# use 1024M memory to cover most scenarios
QB_MEM = "-m 1024"
QB_CPU_KVM = "-cpu host -machine gic-version=3"
# For graphics to work we need to define the VGA device as well as the necessary USB devices
QB_GRAPHICS = "-device virtio-gpu-pci"
QB_OPT_APPEND = "-device qemu-xhci -device usb-tablet -device usb-kbd"
# Virtio Networking support
QB_TAP_OPT = "-netdev tap,id=net0,ifname=@TAP@,script=no,downscript=no"
QB_NETWORK_DEVICE = "-device virtio-net-pci,netdev=net0,mac=@MAC@"
# Virtio block device
QB_ROOTFS_OPT = "-drive id=disk0,file=@ROOTFS@,if=none,format=raw -device virtio-blk-pci,drive=disk0"
# Virtio serial console
QB_SERIAL_OPT = "-device virtio-serial-pci -chardev null,id=virtcon -device virtconsole,chardev=virtcon"
QB_TCPSERIAL_OPT = "-device virtio-serial-pci -chardev socket,id=virtcon,port=@PORT@,host=127.0.0.1 -device virtconsole,chardev=virtcon"

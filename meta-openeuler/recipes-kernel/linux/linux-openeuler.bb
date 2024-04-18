require recipes-kernel/linux/linux-openeuler.inc

COMPATIBLE_MACHINE= "${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', '\
qemuarm64|qemux86|qemux86-64|qemu-aarch64|raspberrypi4-64|generic-x86-64\
', '\
qemuarm|qemuarmv5|qemuarm64|qemux86|qemuppc|qemuppc64|qemumips|qemumips64|qemux86-64|qemuriscv64|qemuriscv32|qemu-aarch64|qemu-arm|raspberrypi4-64|generic-x86-64|qemu-riscv64\
', d)}"


require recipes-kernel/linux/linux-openeuler.inc
# Each machine has its own dedicated configuration file, which is named after
# the machine with the suffix "inc". Each machine's configuration file can
# specify its own variables. For example, for the machine "tspi-3566", when
# setting the PV (process variable), it should be specified as follows: PV:tspi-3566.

COMPATIBLE_MACHINE= "${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', '\
qemuarm64|qemux86|qemux86-64|qemu-aarch64|raspberrypi4-64|generic-x86-64\
', '\
qemuarm|qemuarmv5|qemuarm64|qemux86|qemuppc|qemuppc64|qemumips|qemumips64|qemux86-64|qemuriscv64|qemuriscv32|qemu-aarch64|qemu-arm|raspberrypi4-64|generic-x86-64|qemu-riscv64\
', d)}"

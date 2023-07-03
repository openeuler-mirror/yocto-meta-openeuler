require conf/machine/include/arm/armv8-2a/tune-cortexa55.inc
MACHINE_FEATURES += "efi pci vc4graphics"
MACHINEOVERRIDES =. "rk3568:march64le:"
DEFAULTTUNE = "aarch64"

require conf/multilib.conf
# currently, don't support 32 bit libs
MULTILIBS = ""

ROOTFS_PACKAGE_ARCH = "aarch64"

# set IMAGETYPE and dtb
KERNEL_IMAGETYPE = "Image"
# choose dtb file
RK3568_KERNEL_DTB_NAME ?= "OK3568-C-linux.dtb"
KERNEL_DEVICETREE = "rockchip/${RK3568_KERNEL_DTB_NAME}"
ENABLE_UART = "1"
# serial port enabled in ok3568
CMDLINE_SERIAL = "console=tty1 console=ttyFIQ0,115200"
SERIAL_CONSOLES = "115200;ttyFIQ0"

# arm and arm64 both support -mlittle-endian so no
# need to consider compat32.
TUNE_CCARGS .= " -mlittle-endian"
IMAGE_INSTALL:append = " kernel-modules"

# auto load module during startup
KERNEL_MODULE_AUTOLOAD = "mlan moal "

# set MCS_FEATURES
# rk3568 only supports the "openamp" mechanism,
# and client os only supports uniproton, rtt
MCS_FEATURES = "openamp"
MCS_FEATURES := "${@bb.utils.contains('DISTRO_FEATURES', 'mcs', '${MCS_FEATURES}', '', d)}"

include conf/machine/include/tune-cortexa55.inc
MACHINE_FEATURES += "efi pci vc4graphics"
MACHINEOVERRIDES =. "hi1711:march64le:"
DEFAULTTUNE = "aarch64"

require conf/multilib.conf
# currently, don't support 32 bit libs
MULTILIBS = ""

ROOTFS_PACKAGE_ARCH = "aarch64"

# set IMAGETYPE and dtb
KERNEL_IMAGETYPE = "zImage"
# choose dtb file
KERNEL_DEVICETREE = ""
ENABLE_UART = "1"
# serial port enabled in hi1711
CMDLINE_SERIAL = "ttyS0,115200"
SERIAL_CONSOLES = "115200;ttyS0"

# arm and arm64 both support -mlittle-endian so no
# need to consider compat32.
TUNE_CCARGS .= " -mlittle-endian"
IMAGE_INSTALL_append = " kernel-modules"

# auto load module during startup
KERNEL_MODULE_AUTOLOAD = ""
USE_VT ?= "0"

# set MCS_FEATURES
# hi3093 only supports the "openamp" mechanism,
# and client os only supports uniproton
MCS_FEATURES = "openamp"
MCS_FEATURES := "${@bb.utils.contains('DISTRO_FEATURES', 'mcs', '${MCS_FEATURES}', '', d)}"

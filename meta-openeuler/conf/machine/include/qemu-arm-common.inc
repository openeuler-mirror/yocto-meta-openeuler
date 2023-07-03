# Description: Machine description for little-endian arm32

MACHINEOVERRIDES =. "march32:"
require conf/machine/include/qemu-common.inc
require conf/machine/include/arm/arch-armv7a.inc

#kernel modules to install and autoload
require conf/machine/include/kernel-modules-conf/common.inc
INSTALLMODULES += " \
kernel-module-unix \
"
KERNEL_MODULE_AUTOLOAD = "${INSTALLMODULES}"

TUNE_FEATURES:append = " cortexa9"
TUNE_FEATURES:remove = " vfp"

TUNE_CCARGS .= " -mno-unaligned-access"

# simplest serial console setting, no VT
SERIAL_CONSOLES ?= "115200;ttyAMA0"
USE_VT ?= "0"

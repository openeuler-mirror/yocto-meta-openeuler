# Description: Conf for arm

MACHINEOVERRIDES =. "march32:"
require conf/machine/qemu-common.inc
require conf/machine/include/arm/arch-armv7a.inc

#kernel modules to install and autoload
require conf/machine/kernel-modules-conf/common.inc
INSTALLMODULES += " \
kernel-module-unix \
"
KERNEL_MODULE_AUTOLOAD = "${INSTALLMODULES}"

TUNE_FEATURES_append += " cortexa9"
TUNE_FEATURES_remove += " vfp"

TUNE_CCARGS .= " -mno-unaligned-access"

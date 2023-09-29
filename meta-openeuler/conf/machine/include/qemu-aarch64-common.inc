# Description: Config for arm64 machine

KERNEL_IMAGETYPE =. "zImage"
KERNEL_IMAGETYPE_FOR_MAKE =. "zImage Image"

#kernel modules to install and autoload
require conf/machine/include/kernel-modules-conf/common.inc
require conf/machine/include/kernel-modules-conf/iso-install.inc
KERNEL_MODULE_AUTOLOAD = "${INSTALLMODULES}"

# Different from arm32, here we use armv8a.inc instead
# of conf/machine/include/tune-cortexa53.inc because
# we are not sure our CPU is cortex a53.
require conf/machine/include/arm/arch-armv8a.inc

# but we are sure in compat32 we should use -mcpu=cortexa9.
# This may be not correct, but to make sure compat32 and arm32
# generate the same binary.
# Should not use conf/machine/include/tune-cortexa9.inc directly.
# In case when using compat32, we alert cflags with same way in tune-cortexa9.inc

TUNE_CCARGS .= "${@bb.utils.contains('TUNE_FEATURES', 'cortexa9', ' -mtune=cortex-a9', '', d)}"
MACHINEOVERRIDES =. "${@bb.utils.contains('TUNE_FEATURES', 'cortexa9', 'armv7a:', '' ,d)}"

TUNE_FEATURES:append:virtclass-multilib-lib32 = " cortexa9"
TUNE_FEATURES:remove:virtclass-multilib-lib32 = " vfp"

# simplest serial console setting, no VT
SERIAL_CONSOLES ?= "115200;ttyAMA0"
USE_VT ?= "0"
# make a APPEND cmdline for grub.cfg while using iso with grub
APPEND += " console=ttyAMA0,115200 "

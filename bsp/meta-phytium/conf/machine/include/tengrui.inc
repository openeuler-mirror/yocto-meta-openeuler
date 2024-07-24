require conf/machine/include/arm/arch-armv8a.inc
require conf/multilib.conf
# currently, don't support 32 bit libs
MULTILIBS = ""

DEFAULTTUNE = "aarch64"

ROOTFS_PACKAGE_ARCH = "aarch64"

KERNEL_IMAGETYPE = "Image"

# serial console setting
SERIAL_CONSOLES = "115200;ttyAMA0"

# arm and arm64 both support -mlittle-endian so no
# need to consider compat32.
TUNE_CCARGS .= " -mlittle-endian"

# recovery EFI_PROVIDER option, which is removed in packagegroup-core-boot
EFI_PROVIDER ??= "grub-efi"
IMAGE_INSTALL:append = " ${@bb.utils.contains("MACHINE_FEATURES", "efi", "${EFI_PROVIDER}", "", d)} "

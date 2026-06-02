require conf/machine/include/arm/arch-armv8a.inc
require conf/multilib.conf
# currently, don't support 32 bit libs
MULTILIBS = ""

DEFAULTTUNE = "aarch64"

ROOTFS_PACKAGE_ARCH = "aarch64"

# arm and arm64 both support -mlittle-endian so no
# need to consider compat32.
TUNE_CCARGS .= " -mlittle-endian"

IMAGE_INSTALL:append = " kernel-modules grub-efi"
IMAGE_INSTALL:remove = " syslinux"

# recovery EFI_PROVIDER option, which is removed in packagegroup-core-boot
EFI_PROVIDER ??= "grub-efi"

KERNEL_DEVICETREE ?= " phytium/pe2201-demo-ddr4.dtb phytium/pe2202-chillipi-edu-board.dtb phytium/pe2202-demo-ddr4.dtb phytium/pe2202-miniitx-board.dtb phytium/pe2202-power-board.dtb phytium/pe2204-come-board.dtb phytium/pe2204-demo-ddr4.dtb phytium/pe2204-edu-board.dtb phytium/pe2204-hanwei-board.dtb phytium/pe2204-miniitx-board.dtb phytium/pe2204-vpx-board.dtb phytium/phytiumpi_firefly.dtb"

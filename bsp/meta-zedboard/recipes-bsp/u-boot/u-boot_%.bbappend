# ZedBoard boot flow (fully open source, no FSBL/bootgen):
#   BootROM -> spl/boot.bin (U-Boot SPL, mkimage -T zynqimage) -> u-boot.img
#
# xilinx_zynq_virt_defconfig selects the ps7_init data for the board through
# DEVICE_TREE, which must match the kernel device tree (zynq-zed).
UBOOT_MACHINE = "xilinx_zynq_virt_defconfig"
EXTRA_OEMAKE:append = " DEVICE_TREE=zynq-zed"

# meta-openeuler's u-boot bbappend lists file://boot.cmd which does not exist
# anywhere in the source tree; drop it for this machine.
SRC_URI:remove:zedboard = "file://boot.cmd"

# xilinx_zynq_virt_defconfig builds tools/mkeficapsule, which needs host
# gnutls. EFI capsule generation is not used here, so drop the tool.
#
# The openEuler U-Boot backports default to the bootstd/EFI flow, which
# ignores our boot.scr. Boot the script directly instead, and enable raw
# bitstream programming for the PL (byte-swapped .bin produced by the build).
do_compile:prepend() {
	if grep -q '^CONFIG_TOOLS_MKEFICAPSULE=y' ${B}/.config; then
		sed -i 's/^CONFIG_TOOLS_MKEFICAPSULE=y/# CONFIG_TOOLS_MKEFICAPSULE is not set/' ${B}/.config
	fi

	sed -i -e '/^CONFIG_USE_BOOTCOMMAND=/d' \
	       -e '/^CONFIG_BOOTCOMMAND=/d' \
	       -e '/^CONFIG_AUTOBOOT_MENU_SHOW=/d' \
	       -e '/^# CONFIG_AUTOBOOT_MENU_SHOW is not set/d' ${B}/.config
	printf '%s\n' \
		'CONFIG_USE_BOOTCOMMAND=y' \
		'CONFIG_BOOTCOMMAND="mmc rescan; load mmc 0:1 0x100000 boot.scr; source 0x100000"' \
		'# CONFIG_AUTOBOOT_MENU_SHOW is not set' >> ${B}/.config
}

UBOOT_SUFFIX = "img"
UBOOT_BINARY = "u-boot.img"
SPL_BINARY = "spl/boot.bin"
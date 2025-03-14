PREFERRED_PROVIDER_virtual/bootloader ?= "u-boot-aspeed-sdk"
PREFERRED_PROVIDER_u-boot ?= "u-boot-aspeed-sdk"
PREFERRED_PROVIDER_u-boot-fw-utils ?= "u-boot-fw-utils-aspeed-sdk"

# Build a FIT image and stuff core-image-minimal in it by default.
KERNEL_IMAGETYPE ?= "fitImage"
KERNEL_CLASSES ?= "kernel-fitimage"

WKS_FILE ?= "emmc-aspeed.wks.in"
WKS_FILE_DEPENDS ?= " \
    phosphor-hostfw-image \
    virtual/bootloader \
    virtual/kernel \
"
WKS_HOSTFW_SIZE ?= "5G"
IMAGE_BOOT_FILES ?= "fitImage-${INITRAMFS_IMAGE}-${MACHINE}-${MACHINE};fitImage"

MACHINE_EXTRA_RRECOMMENDS += "udev-aspeed-vuart udev-aspeed-mtd-partitions"
MACHINE_FEATURES += "hw-rng"

MACHINEOVERRIDES =. "aspeed:"

SERIAL_CONSOLES ?= "115200;ttyS4"

DEFAULTTUNE:aspeed-g6 ?= "armv7ahf-vfpv4d16"

UBOOT_ENTRYPOINT:aspeed-g6 ?= "0x80001000"
UBOOT_LOADADDRESS:aspeed-g6 ?= "0x80001000"

# runqemu support
# EXTRA_IMAGEDEPENDS += "qemu-helper-native"
# IMAGE_CLASSES += "qemuboot"
# QB_SYSTEM_NAME = "qemu-system-arm"
# QB_ROOTFS_OPT = "-drive file=@ROOTFS@,if=mtd,format=raw"
# QB_DEFAULT_FSTYPE = "static.mtd"
# # Disable virtio-pci device
# QB_RNG = ""
# QB_NETWORK_DEVICE = "-net nic"
# # Boot from drive
# QB_DEFAULT_KERNEL = "none"
# # runqemu overrides default memory size
# QB_MEM = "-m 512"

# QB_MACHINE:aspeed-g6 = "-machine ast2600-evb"
# QB_MEM:aspeed-g6 = "-m 1G"
# QB_SLIRP_OPT:aspeed-g6 = "-netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp::2443-:443"

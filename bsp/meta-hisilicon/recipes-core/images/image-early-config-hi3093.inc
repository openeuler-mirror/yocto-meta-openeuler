# This file should only be referenced by openeuler-image for customizing early configuration at the image level
# ref: meta-openeuler/recipes-core/images/openeuler-image.bb:
# line 0 |   include recipes-core/images/image-early-config-${MACHINE}.inc
# line 1 |   require openeuler-image-common.inc

IMAGE_FSTYPES = "${@bb.utils.contains("DISTRO_FEATURES", "mpu_solution", " ext4 live cpio.gz ", " cpio.gz ", d)}"
INITRD_IMAGE_LIVE = "initrd-boot"

INITRAMFS_MAXSIZE = "476591"
IMAGE_ROOTFS_SIZE = "387072"

IMAGE_FSTYPES:remove = "iso"
IMAGE_FSTYPES_DEBUGFS = "cpio.gz"

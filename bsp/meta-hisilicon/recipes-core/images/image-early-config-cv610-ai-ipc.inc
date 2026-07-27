# This file should only be referenced by openeuler-image for customizing early configuration at the image level
# ref: meta-openeuler/recipes-core/images/openeuler-image.bb:
# line 0 |   include recipes-core/images/image-early-config-${MACHINE}.inc
# line 1 |   require openeuler-image-common.inc

IMAGE_FSTYPES = "ext4 cpio.gz ubi"
IMAGE_FSTYPES:remove = "iso"
IMAGE_FSTYPES_DEBUGFS = "cpio.gz"

# rootfs 120M
MKUBIFS_ARGS = "-F -m 2048 -e 126976 -c 960"
UBINIZE_ARGS = "-m 2048 -p 131072"
UBI_VOLNAME = "ubifs"

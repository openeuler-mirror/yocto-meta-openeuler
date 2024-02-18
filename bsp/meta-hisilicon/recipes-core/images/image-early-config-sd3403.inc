# This file should only be referenced by openeuler-image for customizing early configuration at the image level
# ref: meta-openeuler/recipes-core/images/openeuler-image.bb:
# line 0 |   include recipes-core/images/image-early-config-${MACHINE}.inc
# line 1 |   require openeuler-image-common.inc

IMAGE_FSTYPES = "ext4"
IMAGE_FSTYPES:remove = "iso"
IMAGE_FSTYPES_DEBUGFS = "cpio.gz"
INITRAMFS_MAXSIZE = "476591"


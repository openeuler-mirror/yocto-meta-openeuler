# This file should only be referenced by openeuler-image for customizing early configuration at the image level
# ref: meta-openeuler/recipes-core/images/openeuler-image.bb:
# line 0 |   include recipes-core/images/image-early-config-${MACHINE}.inc
# line 1 |   require openeuler-image-common.inc

IMAGE_FSTYPES = " cpio.gz ${@bb.utils.contains('DISTRO_FEATURES', '3591fullimg', '3591-sdimg ext4', '', d)} "
IMAGE_FSTYPES:remove = "iso tar.gz"
IMAGE_FSTYPES_DEBUGFS = "cpio.gz"

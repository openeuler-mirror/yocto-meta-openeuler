# Simple initramfs image. Mostly used for live images.
# reference: yoto-poky/meta/recipes-core/images/core-image-minimal-initramfs.bb

# no host package
TOOLCHAIN_HOST_TASK = ""

SUMMARY = "Simple initramfs image. Mostly used for live images"

INITRAMFS_SCRIPTS ?= "\
                        initramfs-module-install-efi \
                     "

VIRTUAL-RUNTIME_base-utils = "packagegroup-core-boot"
PACKAGE_INSTALL = "${INITRAMFS_SCRIPTS} \
        ${VIRTUAL-RUNTIME_base-utils} \
        base-passwd \
        ${ROOTFS_BOOTSTRAP_INSTALL} \
        packagegroup-kernel-modules \
"

export IMAGE_BASENAME = "openeuler-image-live"

IMAGE_FSTYPES = "cpio.gz"
IMAGE_FSTYPES_DEBUGFS = "cpio.gz"
INITRAMFS_MAXSIZE = "262144"
do_image_cpio[depends] ?= ""

# make install or nologin
set_permissions_from_rootfs_append() {
   sed -i "s#respawn:/sbin/getty.*#respawn:-/bin/sh /init.d/install-efi.sh#g" ./etc/inittab
}

require recipes-core/images/${MACHINE}.inc
require openeuler-image-common.inc

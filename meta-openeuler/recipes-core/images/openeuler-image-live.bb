# Simple initramfs image. Mostly used for live images.
# reference: yoto-poky/meta/recipes-core/images/core-image-minimal-initramfs.bb

# no host package
TOOLCHAIN_HOST_TASK = ""

SUMMARY = "Simple initramfs image. Mostly used for live images"

INITRAMFS_SCRIPTS ?= "\
                        initramfs-module-install-efi \
                     "

# we want a non systemd init manager, packagegroup-core-boot-live is for it.
VIRTUAL-RUNTIME_base-utils = "packagegroup-core-boot-live"
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

# make install or nologin when using busybox-inittab
set_permissions_from_rootfs:append() {
    cd "${IMAGE_ROOTFS}"
    if [ -e ./etc/inittab ];then
        sed -i "s#respawn:/sbin/getty.*#respawn:-/bin/sh /init.d/install-efi.sh#g" ./etc/inittab
    fi
    cd -
}

require openeuler-image-common.inc

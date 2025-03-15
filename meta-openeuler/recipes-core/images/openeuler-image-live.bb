# Simple initramfs image. Mostly used for live images.
# reference: yoto-poky/meta/recipes-core/images/core-image-minimal-initramfs.bb

SUMMARY = "Simple initramfs image. Mostly used for live images"

# install scripts for efi boot
INITRAMFS_SCRIPTS ?= "\
                      initramfs-module-install-efi \
                     "

# packages containing necessary tools required in image live,
PACKAGE_INSTALL = "${INITRAMFS_SCRIPTS} \
        packagegroup-core-boot-live \
        ${ROOTFS_BOOTSTRAP_INSTALL} \
        kernel-modules \
        packagegroup-kernel-modules \
        efivar efibootmgr \
"

export IMAGE_BASENAME = "openeuler-image-live"
IMAGE_FSTYPES = "${INITRAMFS_FSTYPES}"

# directly call install-efi.sh after initialization
set_permissions_from_rootfs:append() {
    # if sysvinit is used, modify inittab to call install-efi.sh
    if ${@bb.utils.contains('DISTRO_FEATURES','sysvinit','true','false',d)}; then
        cd "${IMAGE_ROOTFS}"
        if [ -e ./etc/inittab ];then
            sed -i "s#respawn:/sbin/getty.*#respawn:-/bin/sh /init.d/install-efi.sh#g" ./etc/inittab
        fi
        cd -
    fi

    if ${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'true', 'false', d)}; then
        # Mask getty.target for the live image. We'll use tty device in install-efi.sh.
        cd "${IMAGE_ROOTFS}"
        ln -sf /dev/null ./etc/systemd/system/getty.target
        cd -
    fi
}

require openeuler-image-common.inc

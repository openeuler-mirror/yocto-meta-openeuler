SUMMARY = "A small image just capable of openEuler Embedded's mcs feature"

require openeuler-image-common.inc
require openeuler-image-sdk.inc

IMAGE_INSTALL += " \
packagegroup-core-boot \
packagegroup-kernel-modules \
packagegroup-openssh \
mcs-linux \
mcs-km \
screen \
libgcc-external \
zephyr-image \
${@bb.utils.contains('MCS_FEATURES', 'jailhouse', 'jailhouse', '', d)} \
"

# make no login
set_permissions_from_rootfs_append() {
    cd "${IMAGE_ROOTFS}"
    if [ -f ./etc/inittab ]; then
        sed -i "s#respawn:/sbin/getty.*#respawn:-/bin/sh#g" ./etc/inittab
    fi
    cd -
}

#image configuration for aarch64
require rk3568.inc

IMAGE_INSTALL:remove = " \
packagegroup-core-base-utils \
"

# make no login
set_permissions_from_rootfs:append() {
    cd "${IMAGE_ROOTFS}"
    if [ -f ./etc/inittab ]; then
        sed -i "s#respawn:/sbin/getty.*#respawn:-/bin/sh#g" ./etc/inittab
    fi
    cd -
}
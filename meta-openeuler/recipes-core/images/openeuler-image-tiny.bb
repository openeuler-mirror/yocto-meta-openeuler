# no host package for image-tiny
TOOLCHAIN_HOST_TASK = ""

SUMMARY = "A small image just capable of allowing a device to boot."

require recipes-core/images/${MACHINE}.inc
require openeuler-image-common.inc

IMAGE_INSTALL += " \
packagegroup-core-boot \
"

# make no login
set_permissions_from_rootfs_append() {
   sed -i "s#respawn:/sbin/getty.*#respawn:-/bin/sh#g" ./etc/inittab
}

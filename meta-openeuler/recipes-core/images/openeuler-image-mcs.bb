SUMMARY = "A small image just capable of openEuler Embedded's mcs feature"

require openeuler-image-common.inc
require openeuler-image-sdk.inc

# basic packages required, e.g., boot, ssh ,debug
IMAGE_INSTALL += " \
packagegroup-core-boot \
packagegroup-kernel-modules \
packagegroup-openssh \
screen \
libgcc-external \
"

## MCS_FEATURES = "<openamp|jailhouse>  [client os]  [other properties] "
## no machine info in MCS_FEATURES
## select the implementation of bottom foundation
# if openamp is used, mcs-linux and mcs-km will be included
IMAGE_INSTALL += " ${@bb.utils.contains('MCS_FEATURES', 'openamp', 'mcs-linux mcs-km', '', d)} "
# if jailhouse is used, jailhouse will be included
IMAGE_INSTALL += " ${@bb.utils.contains('MCS_FEATURES', 'jailhouse', 'jailhouse', '', d)} "

## select client os
IMAGE_INSTALL += " ${@bb.utils.contains('MCS_FEATURES', 'zephyr', 'zephyr-image', '', d)} "

# make no login
set_permissions_from_rootfs_append() {
    cd "${IMAGE_ROOTFS}"
    if [ -f ./etc/inittab ]; then
        sed -i "s#respawn:/sbin/getty.*#respawn:-/bin/sh#g" ./etc/inittab
    fi
    cd -
}

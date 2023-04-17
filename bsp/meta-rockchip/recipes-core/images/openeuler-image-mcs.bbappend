# Zephyr and Jailhouse do not currently support rk3568, so remove them.
IMAGE_INSTALL_remove = " \
    zephyr-image \
    ${@bb.utils.contains('MCS_FEATURES', 'jailhouse', 'jailhouse', '', d)} \
    "

# fix do_rootfs error:
# /bin/sh: line 1: useradd: command not found
do_rootfs[depends] = "opkg-utils-native:do_populate_sysroot"

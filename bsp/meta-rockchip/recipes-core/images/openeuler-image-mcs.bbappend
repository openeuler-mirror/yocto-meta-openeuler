# fix do_rootfs error:
# /bin/sh: line 1: useradd: command not found
do_rootfs[depends] = "opkg-utils-native:do_populate_sysroot"

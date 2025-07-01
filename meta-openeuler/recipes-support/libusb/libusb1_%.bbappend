# the main bb file: yocto-poky/meta/recipes-support/libusb/libusb1_1.0.26.bb

OPENEULER_LOCAL_NAME = "libusbx"

PACKAGECONFIG:class-target:remove = "${@bb.utils.contains('VIRTUAL-RUNTIME_dev_manager', 'busybox-mdev', 'udev', '', d)}"

SRC_URI:append = " \
    file://libusb-${PV}.tar.bz2 \
"

SRC_URI[md5sum] = "9c75660dfe1d659387c37b28c91e3160"
SRC_URI[sha256sum] = "12ce7a61fc9854d1d2a1ffe095f7b5fac19ddba095c259e6067a46500381b5a5"

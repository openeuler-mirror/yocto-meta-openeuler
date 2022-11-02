PV = "1.0.26"
OPENEULER_REPO_NAME = "libusbx"

SRC_URI_remove = " \
	https://github.com/libusb/libusb/releases/download/v${PV}/libusb-${PV}.tar.bz2 \
"

SRC_URI_append = " \
	file://libusb-${PV}.tar.bz2 \
"

SRC_URI[sha256sum] = "12ce7a61fc9854d1d2a1ffe095f7b5fac19ddba095c259e6067a46500381b5a5"

# no uedev in openeuler
PACKAGECONFIG_class-target_remove += "udev"

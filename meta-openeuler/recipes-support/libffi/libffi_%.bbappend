PV = "3.4.4"
OPENEULER_BRANCH = "openEuler-23.03"

LIC_FILES_CHKSUM = "file://LICENSE;md5=32c0d09a0641daf4903e5d61cc8f23a8"

# add not-win32.patch to fix libdir error
SRC_URI = " \
    file://${BPN}-${PV}.tar.gz \
    file://not-win32.patch \
"

#patches from openeuler
SRC_URI += " \
"

SRC_URI[md5sum] = "0da1a5ed7786ac12dcbaf0d499d8a049"
SRC_URI[sha256sum] = "d66c56ad259a82cf2a9dfc408b32bf5da52371500b84745f7fb8b645712df676"

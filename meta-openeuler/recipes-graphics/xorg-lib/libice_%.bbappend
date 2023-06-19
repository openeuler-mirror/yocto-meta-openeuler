require openeuler-xorg-lib-common.inc

PV = "1.1.1"

SRC_URI:prepend = "file://0002-Add-getentropy-emulation-through-syscall.patch \
           "

SRC_URI[sha256sum] = "04fbd34a11ba08b9df2e3cdb2055c2e3c1c51b3257f683d7fcf42dabcf8e1210"

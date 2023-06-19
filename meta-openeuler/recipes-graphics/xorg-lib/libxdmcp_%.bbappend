require openeuler-xorg-lib-common.inc

PV = "1.1.4"

SRC_URI:prepend = "file://0003-Add-getentropy-emulation-through-syscall.patch \
           "

SRC_URI[sha256sum] = "55041a8ff8992ab02777478c4b19c249c0f8399f05a752cb4a1a868a9a0ccb9a"

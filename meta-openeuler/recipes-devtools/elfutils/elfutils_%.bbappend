PV = "0.187"

# add patches from openeuler
SRC_URI += " \
    file://Fix-segfault-in-eu-ar-m.patch \
    file://elfutils-${PV}.tar.bz2 \
"

SRC_URI[sha256sum] = "e70b0dfbe610f90c4d1fe0d71af142a4e25c3c4ef9ebab8d2d72b65159d454c8"

LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504 \
                    file://debuginfod/debuginfod-client.c;endline=27;md5=7eb69ae4d5654e590c840538256a7bfe \
                    "

# delete conflict patches from poky
SRC_URI_remove += " \
           file://0001-add-support-for-ipkg-to-debuginfod.cxx.patch \
           https://sourceware.org/elfutils/ftp/${PV}/${BP}.tar.bz2 \
"
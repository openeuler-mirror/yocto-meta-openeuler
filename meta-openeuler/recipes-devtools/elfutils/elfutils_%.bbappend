# the main bb file: yocto-poky/meta/recipes-devtools/elfutils/elfutils_0.186.bb
PV = "0.190"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# the path removed in 0.187
SRC_URI:remove = " \
    file://0001-debuginfod-fix-compilation-on-platforms-without-erro.patch \
    file://0001-debuginfod-debuginfod-client.c-use-long-for-cache-ti.patch \
    file://0001-libasm-may-link-with-libbz2-if-found.patch \
"

# add patches from openeuler
SRC_URI:append = " \
    file://${BP}.tar.bz2 \
    file://Fix-segfault-in-eu-ar-m.patch \
    file://Fix-issue-of-moving-files-by-ar-or-br.patch \
    file://CVE-2024-25260.patch \
"

SRC_URI[sha256sum] = "e70b0dfbe610f90c4d1fe0d71af142a4e25c3c4ef9ebab8d2d72b65159d454c8"

LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504 \
                    file://debuginfod/debuginfod-client.c;endline=27;md5=7eb69ae4d5654e590c840538256a7bfe \
                    "

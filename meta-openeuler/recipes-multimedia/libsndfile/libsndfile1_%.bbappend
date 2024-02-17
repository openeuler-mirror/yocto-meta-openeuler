# main bb: yocto-poky/meta/recipes-multimedia/libsndfile/libsndfile1_1.0.31.bb

OPENEULER_LOCAL_NAME = "libsndfile"

PV = "1.2.0"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# this patch no need for 1.2.0
SRC_URI:remove = " \
        file://0001-flac-Fix-improper-buffer-reusing-732.patch \
"

SRC_URI += " \
        file://${OPENEULER_LOCAL_NAME}/libsndfile-${PV}.tar.xz \
"

S = "${WORKDIR}/libsndfile-${PV}"

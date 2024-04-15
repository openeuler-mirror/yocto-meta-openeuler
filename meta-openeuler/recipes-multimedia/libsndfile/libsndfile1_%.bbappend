# main bb: yocto-poky/meta/recipes-multimedia/libsndfile/libsndfile1_1.0.31.bb

OPENEULER_REPO_NAME = "libsndfile"

PV = "1.2.2"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# this patch no need for 1.2.2
SRC_URI:remove = " \
        file://0001-flac-Fix-improper-buffer-reusing-732.patch \
"

# the follow patch will occur gsm lib not found
# file://libsndfile-1.0.25-system-gsm.patch
SRC_URI += " \
        file://libsndfile-${PV}.tar.xz \
"

# poky patch
SRC_URI += " \
        file://cve-2022-33065.patch \
        "

SRC_URI[md5sum] = "04e2e6f726da7c5dc87f8cf72f250d04"
SRC_URI[sha256sum] = "3799ca9924d3125038880367bf1468e53a1b7e3686a934f098b7e1d286cdb80e"

S = "${WORKDIR}/libsndfile-${PV}"

# main bbfile: yocto-poky/meta/recipes-multimedia/libtiff/tiff_4.2.0.bb
# new ref upstream: openembedded-core/meta/recipes-multimedia/libtiff/tiff_4.5.0.bb

OPENEULER_REPO_NAME = "libtiff"
OPENEULER_BRANCH = "master"
OPENEULER_SRC_URI_REMOVE = "https http git"

LIC_FILES_CHKSUM = "file://LICENSE.md;md5=a3e32d664d6db1386b4689c8121531c3"

PV = "4.5.0"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# source patch from poky
SRC_URI = " \
        file://CVE-2022-48281.patch \
        file://CVE-2023-2731.patch \
        file://CVE-2023-26965.patch \
"

# source change to openEuler
SRC_URI:append = " \
        file://tiff-${PV}.tar.gz \
        file://backport-0001-CVE-2023-0795-0796-0797-0798-0799.patch \
        file://backport-0002-CVE-2023-0795-0796-0797-0798-0799.patch \
        file://backport-CVE-2023-0800-0801-0802-0803-0804.patch \
        "

# the list patches apply failed
# file://backport-CVE-2022-48281.patch                               

PACKAGECONFIG[zstd] = "--enable-zstd,--disable-zstd,zstd,"
PACKAGECONFIG[libdeflate] = "--enable-libdeflate,--disable-libdeflate,libdeflate,"


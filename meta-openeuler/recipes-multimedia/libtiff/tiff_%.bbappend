# main bbfile: yocto-poky/meta/recipes-multimedia/libtiff/tiff_4.3.0.bb
# new ref upstream: openembedded-core/meta/recipes-multimedia/libtiff/tiff_4.5.1.bb

PV = "4.6.0"

LIC_FILES_CHKSUM = "file://LICENSE.md;md5=a3e32d664d6db1386b4689c8121531c3"

# source change to openEuler
SRC_URI = "file://${BP}.tar.gz \
        file://backport-CVE-2023-6228.patch \
        file://backport-0001-CVE-2023-6277.patch \
        file://backport-0002-CVE-2023-6277.patch \
        file://backport-0003-CVE-2023-6277.patch \
        "                             

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"
# poky patch
# the list patchs apply failed
# file://CVE-2023-6277-At-image-reading-compare-data-size-of-some-tags-data.patch
# file://CVE-2023-6277-At-image-reading-compare-data-size-of-some-tags-data-2.patch
# file://CVE-2023-6277-Apply-1-suggestion-s-to-1-file-s.patch
# file://CVE-2023-6228.patch
# file://CVE-2023-52356.patch
SRC_URI:append = " \
        file://CVE-2023-52355-0001.patch \
        file://CVE-2023-52355-0002.patch \
        "

CVE_CHECK_IGNORE:remove = " CVE-2015-7313 CVE-2022-1622 CVE-2022-1623 CVE-2022-1210 "
CVE_STATUS[CVE-2015-7313] = "fixed-version: Tested with check from https://security-tracker.debian.org/tracker/CVE-2015-7313 and already 4.3.0 doesn't have the issue"
CVE_STATUS[CVE-2023-3164] = "cpe-incorrect: Issue only affects the tiffcrop tool not compiled by default since 4.6.0"

PACKAGECONFIG[zstd] = "--enable-zstd,--disable-zstd,zstd,"
PACKAGECONFIG[libdeflate] = "--enable-libdeflate,--disable-libdeflate,libdeflate,"

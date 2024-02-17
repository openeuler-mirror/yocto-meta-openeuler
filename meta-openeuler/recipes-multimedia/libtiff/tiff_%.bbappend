# main bbfile: yocto-poky/meta/recipes-multimedia/libtiff/tiff_4.3.0.bb
# new ref upstream: openembedded-core/meta/recipes-multimedia/libtiff/tiff_4.5.1.bb

PV = "4.5.1"

LIC_FILES_CHKSUM = "file://LICENSE.md;md5=a3e32d664d6db1386b4689c8121531c3"

# source change to openEuler
SRC_URI = "file://tiff-${PV}.tar.gz \
        file://backport-CVE-2023-38288.patch \
        file://backport-CVE-2023-38289.patch \
        "                             

PACKAGECONFIG[zstd] = "--enable-zstd,--disable-zstd,zstd,"
PACKAGECONFIG[libdeflate] = "--enable-libdeflate,--disable-libdeflate,libdeflate,"

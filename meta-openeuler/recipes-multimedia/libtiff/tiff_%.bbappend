# main bbfile: yocto-poky/meta/recipes-multimedia/libtiff/tiff_4.2.0.bb
# new ref upstream: openembedded-core/meta/recipes-multimedia/libtiff/tiff_4.5.0.bb

OPENEULER_REPO_NAME = "libtiff"
OPENEULER_BRANCH = "master"
OPENEULER_SRC_URI_REMOVE = "https http git"

LIC_FILES_CHKSUM = "file://LICENSE.md;md5=a3e32d664d6db1386b4689c8121531c3"
PV = "4.5.0"

# source change to openEuler
SRC_URI += " \
        file://tiff-${PV}.tar.gz \
        file://backport-CVE-2022-48281.patch \
        file://backport-0001-CVE-2023-0795-0796-0797-0798-0799.patch \
        file://backport-0002-CVE-2023-0795-0796-0797-0798-0799.patch \
        file://backport-CVE-2023-0800-0801-0802-0803-0804.patch \
        "

# no need in 4.5.0
CVE_CHECK_WHITELIST:remove += "CVE-2015-7313"

# sync from 4.5.0 bb:
CVE_CHECK_IGNORE += "CVE-2015-7313"                                 
# These issues only affect libtiff post-4.3.0 but before 4.4.0,     
# caused by 3079627e and fixed by b4e79bfa.                         
CVE_CHECK_IGNORE += "CVE-2022-1622 CVE-2022-1623"                   
# Issue is in jbig which we don't enable                            
CVE_CHECK_IGNORE += "CVE-2022-1210"                                 

PACKAGECONFIG[jbig] = "--enable-jbig,--disable-jbig,jbig,"
PACKAGECONFIG[webp] = "--enable-webp,--disable-webp,libwebp,"
PACKAGECONFIG[zstd] = "--enable-zstd,--disable-zstd,zstd,"
PACKAGECONFIG[libdeflate] = "--enable-libdeflate,--disable-libdeflate,libdeflate,"


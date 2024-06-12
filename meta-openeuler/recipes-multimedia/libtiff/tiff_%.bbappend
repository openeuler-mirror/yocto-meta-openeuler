# main bbfile: yocto-poky/meta/recipes-multimedia/libtiff/tiff_4.2.0.bb
# new ref upstream: openembedded-core/meta/recipes-multimedia/libtiff/tiff_4.5.0.bb

OPENEULER_REPO_NAME = "libtiff"
OPENEULER_SRC_URI_REMOVE = "https http git"

PV = "4.3.0"

# source change to openEuler
SRC_URI += " \
    file://tiff-${PV}.tar.gz \
    file://backport-CVE-2022-0561.patch \
    file://backport-CVE-2022-0562.patch \
    file://backport-0001-CVE-2022-22844.patch \
    file://backport-0002-CVE-2022-22844.patch \
    file://backport-0003-CVE-2022-22844.patch \
    file://backport-CVE-2022-0891.patch \
    file://backport-CVE-2022-0907.patch \
    file://backport-CVE-2022-0908.patch \
    file://backport-CVE-2022-0865.patch \
    file://backport-CVE-2022-0909.patch \
    file://backport-CVE-2022-0924.patch \
    file://backport-CVE-2022-1355.patch \
    file://backport-0001-CVE-2022-1622-CVE-2022-1623.patch \
    file://backport-0002-CVE-2022-1622-CVE-2022-1623.patch \
    file://backport-CVE-2022-1354.patch \
    file://backport-CVE-2022-2867-CVE-2022-2868-CVE-2022-2869.patch \
    file://backport-0001-CVE-2022-2953-CVE-2022-2519-CVE-2022-2520-CVE-2022-2521.patch \
    file://backport-0002-CVE-2022-2953-CVE-2022-2519-CVE-2022-2520-CVE-2022-2521.patch \
    file://backport-CVE-2022-2056-CVE-2022-2057-CVE-2022-2058.patch \
    file://backport-CVE-2022-3597-CVE-2022-3626-CVE-2022-3627.patch \
    file://backport-0001-CVE-2022-3570-CVE-2022-3598.patch \
    file://backport-0002-CVE-2022-3570-CVE-2022-3598.patch \
    file://backport-0003-CVE-2022-3570-CVE-2022-3598.patch \
    file://backport-CVE-2022-3599.patch \
    file://backport-CVE-2022-3970.patch \
    file://backport-CVE-2022-48281.patch \
    file://backport-0001-CVE-2023-0795-0796-0797-0798-0799.patch \
    file://backport-0002-CVE-2023-0795-0796-0797-0798-0799.patch \
    file://backport-CVE-2023-0800-0801-0802-0803-0804.patch \
    file://backport-CVE-2023-2731.patch \
    file://backport-CVE-2023-26965.patch \
    file://backport-CVE-2023-3316.patch \
    file://backport-CVE-2023-25433.patch \
    file://backport-CVE-2023-26966.patch \
    file://backport-CVE-2023-2908.patch \
    file://backport-CVE-2023-3576.patch \
    file://backport-CVE-2023-38288.patch \
    file://backport-CVE-2023-38289.patch \
    file://backport-CVE-2023-3618.patch \
    file://backport-CVE-2022-40090.patch \
    file://backport-CVE-2022-34526.patch \
    file://backport-CVE-2023-6228.patch \
    file://backport-CVE-2023-1916-CVE-2023-3164.patch \
    file://fix-raw2tiff-floating-point-exception.patch \
    file://backport-0001-CVE-2023-6277.patch \
    file://backport-0002-CVE-2023-6277.patch \
    file://backport-0003-CVE-2023-6277.patch \
"

# Tested with check from https://security-tracker.debian.org/tracker/CVE-2015-7313
# and 4.3.0 doesn't have the issue
CVE_CHECK_WHITELIST += "CVE-2015-7313"



# main bbfile: yocto-poky/meta/recipes-extended/tar/tar_1.34.bb
PV = "1.34"

# Use the source packages from openEuler
SRC_URI_remove = "${GNU_MIRROR}/tar/tar-${PV}.tar.bz2"
SRC_URI_prepend = "file://tar-${PV}.tar.xz \
        file://backport-CVE-2022-48303.patch \
        file://tar-1.28-loneZeroWarning.patch \
        file://tar-1.28-vfatTruncate.patch \
        file://tar-1.29-wildcards.patch \
        file://tar-1.28-atime-rofs.patch \
        file://tar-1.28-document-exclude-mistakes.patch \
        file://tar-Add-sw64-architecture.patch \
        file://backport-CVE-2023-39804.patch \
"

SRC_URI[md5sum] = "aa1621ec7013a19abab52a8aff04fe5b"
SRC_URI[sha256sum] = "3e1e518ffc912f86608a8cb35e4bd41ad1aec210df2a47aaa1f95e7f5576ef56"

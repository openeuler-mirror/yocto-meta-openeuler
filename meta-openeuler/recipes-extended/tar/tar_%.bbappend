# main bbfile: yocto-poky/meta/recipes-extended/tar/tar_1.34.bb
PV="1.35"

LIC_FILES_CHKSUM = "file://COPYING;md5=1ebbd3e34237af26da5dc08a4e440464"

# Use the source packages from openEuler
SRC_URI:remove = " \
        file://CVE-2022-48303.patch \
        "
SRC_URI:prepend = "file://${BP}.tar.xz \
        file://backport-CVE-2022-48303.patch \
        file://tar-1.28-loneZeroWarning.patch \
        file://tar-1.28-vfatTruncate.patch \
        file://tar-1.29-wildcards.patch \
        file://tar-1.28-atime-rofs.patch \
        file://tar-1.28-document-exclude-mistakes.patch \
        file://tar-1.33-fix-capabilities-test.patch \
        file://tar-1.35-add-forgotten-tests-from-upstream.patch \
        file://tar-1.35-revert-fix-savannah-bug-633567.patch \
        file://tar-Add-sw64-architecture.patch \
"

SRC_URI[md5sum] = "aa1621ec7013a19abab52a8aff04fe5b"
SRC_URI[sha256sum] = "3e1e518ffc912f86608a8cb35e4bd41ad1aec210df2a47aaa1f95e7f5576ef56"

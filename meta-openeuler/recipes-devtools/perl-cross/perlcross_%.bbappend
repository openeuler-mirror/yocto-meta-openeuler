# main bbfile: yocto-poky/meta/recipes-devtools/perl-cross/perlcross_1.3.7.bb

PV = "1.5"

OPENEULER_LOCAL_NAME = "oee_archive"

SRC_URI:remove = " \
            https://github.com/arsv/perl-cross/releases/download/${PV}/perl-cross-${PV}.tar.gz;name=perl-cross \
            file://0001-Makefile-check-the-file-if-patched-or-not.patch \
"

# get tarball locally
SRC_URI += "file://${OPENEULER_LOCAL_NAME}/${BPN}/perl-cross-${PV}.tar.gz;name=perl-cross"

SRC_URI[sha256sum] = "d744a390939e2ebb9a12f6725b4d9c19255a141d90031eff90ea183fdfcbf211"

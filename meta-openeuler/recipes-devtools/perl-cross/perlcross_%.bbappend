# main bbfile: yocto-poky/meta/recipes-devtools/perl-cross/perlcross_1.3.7.bb

PV = "1.5"

inherit oee-archive

SRC_URI:remove = " \
            file://0001-Makefile-check-the-file-if-patched-or-not.patch \
"

# get tarball locally
SRC_URI += "file://perl-cross-${PV}.tar.gz;name=perl-cross"

SRC_URI[sha256sum] = "d744a390939e2ebb9a12f6725b4d9c19255a141d90031eff90ea183fdfcbf211"

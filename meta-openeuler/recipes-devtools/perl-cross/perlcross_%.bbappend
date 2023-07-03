# main bbfile: yocto-poky/meta/recipes-devtools/perl-cross/perlcross_1.3.7.bb

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:remove = "https://github.com/arsv/perl-cross/releases/download/${PV}/perl-cross-${PV}.tar.gz;name=perl-cross"

# get tarball locally
SRC_URI += "file://perl-cross-${PV}.tar.gz;name=perl-cross"

SRC_URI[sha256sum] = "77f13ca84a63025053852331b72d4046c1f90ded98bd45ccedea738621907335"

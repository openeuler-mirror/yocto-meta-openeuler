# main bbfile: https://cgit.openembedded.org/openembedded-core/tree/meta/recipes-devtools/perl-cross/perlcross_1.4.bb

SRC_URI_remove = " \
        https://github.com/arsv/perl-cross/releases/download/${PV}/perl-cross-${PV}.tar.gz;name=perl-cross \
"

# get tarball locally
SRC_URI += " \
        file://perl-cross-${PV}.tar.gz;name=perl-cross \
"

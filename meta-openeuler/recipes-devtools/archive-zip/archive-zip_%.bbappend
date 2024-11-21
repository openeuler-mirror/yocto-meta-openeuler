# source bb: yocto-meta-openeuler/meta-openeuler/recipes-devtools/archive-zip/archive-zip_1.31.bb
PV = "1.68"

SRC_URI:prepend = "file://Archive-Zip-${PV}.tar.gz \
"

S = "${WORKDIR}/Archive-Zip-${PV}"

LICENSE = "CLOSED"

EXTRA_PERLFLAGS:remove = "-I ${STAGING_LIBDIR_NATIVE}/perl-native/perl/${@get_perl_version(d)}"

SRC_URI[sha256sum] = "ede64f6c8ecad7360fe5d8b20379f8a09afe7e7ba5f39fa10e933e798566a98c"

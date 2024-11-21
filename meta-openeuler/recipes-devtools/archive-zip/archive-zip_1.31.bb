DESCRIPTION = "perl interface to ZIP archive files"
SECTION = "libs"
LICENSE = "Artistic-1.0 | GPL-1.0-or-later"
LIC_FILES_CHKSUM = "file://LICENSE;md5=385c55653886acac3821999a3ccd17b3"

PATCHREV = "04"

SRC_URI = "http://www.cpan.org/authors/id/A/AD/ADAMK/Archive-Zip-${PV}_${PATCHREV}.tar.gz"
SRC_URI[md5sum] = "491adb57024059e74767bb56040c2ecb"
SRC_URI[sha256sum] = "ede64f6c8ecad7360fe5d8b20379f8a09afe7e7ba5f39fa10e933e798566a98c"

inherit cpan

DEPENDS += "zlib"

S = "${WORKDIR}/Archive-Zip-${PV}_${PATCHREV}"

EXTRA_PERLFLAGS = "-I ${STAGING_LIBDIR_NATIVE}/perl-native/perl/${@get_perl_version(d)}"

BBCLASSEXTEND = "native"

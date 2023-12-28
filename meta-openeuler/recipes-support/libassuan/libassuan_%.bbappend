PV = "2.5.5"

SRC_URI = "\
        file://libassuan-${PV}.tar.bz2 \
        file://backport-libassuan-2.5.2-multilib.patch \
        file://backport-tests-Avoid-leaking-file-descriptors-on-errors.patch \
"

# add patch from poky to fix gpgme configure error: cannot find libassuan
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
SRC_URI += " \
           file://libassuan-add-pkgconfig-support.patch \
          "

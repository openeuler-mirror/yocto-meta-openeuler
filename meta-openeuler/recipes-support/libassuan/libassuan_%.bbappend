PV = "2.5.5"

SRC_URI = "\
        https://gnupg.org/ftp/gcrypt/libassuan/libassuan-${PV}.tar.bz2 \
        file://backport-libassuan-2.5.2-multilib.patch \
        file://backport-tests-Avoid-leaking-file-descriptors-on-errors.patch \
"

# add patch from poky to fix gpgme configure error: cannot find libassuan
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += " \
           file://libassuan-add-pkgconfig-support.patch \
          "

SRC_URI[sha256sum] = "8e8c2fcc982f9ca67dcbb1d95e2dc746b1739a4668bc20b3a3c5be632edb34e4"

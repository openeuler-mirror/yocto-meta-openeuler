# main bb file: yocto-meta-openembedded/meta-oe/recipes-printing/qpdf/qpdf_10.6.3.bb

PV = "11.1.0"

DEPENDS = "zlib jpeg gnutls"

SRC_URI:remove = "${SOURCEFORGE_MIRROR}/qpdf/qpdf-${PV}.tar.gz \
                 "
SRC_URI:prepend = "file://${BPN}-${PV}.tar.gz \
                  "
SRC_URI[sha256sum] = "34a7cf3ac6e239510e9a20d7cbe10a4aff0f572c20e0a9bed0badb820a69e22d"

inherit cmake pkgconfig gettext

EXTRA_OECMAKE = ' \
        -DRANDOM_DEVICE="/dev/random" \
        -DBUILD_STATIC_LIBS=OFF \
        -DALLOW_CRYPTO_NATIVE=OFF \
        -DUSE_IMPLICIT_CRYPTO=OFF \
        -DREQUIRE_CRYPTO_GNUTLS=1 \
        -DUSE_IMPLICIT_CRYPTO=0 \
'

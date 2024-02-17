# main bbfile: yocto-meta-openembedded/meta-oe/recipes-support/asio/asio_1.18.1.bb

# version in openEuler
PV = "1.16.1"


SRC_URI += " \
        file://${BP}.tar.gz \
        "

SRC_URI[md5sum] = "d34b58ce6e452eeb142d90d48d09422b"
SRC_URI[sha256sum] = "f818986015f26002dfade21f7769aff4e6cd1e720373750536e5e5d00cf922af"

LIC_FILES_CHKSUM = "file://COPYING;md5=de86c8210a433f72bd3cc98e797a6084"
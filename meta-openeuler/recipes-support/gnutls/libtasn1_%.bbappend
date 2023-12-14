# source bb file: yocto-poky/meta/recipes-support/gnutls/libtasn1_4.16.0.bb

PV = "4.19.0"

SRC_URI:remove = "${GNU_MIRROR}/libtasn1/libtasn1-${PV}.tar.gz \
"

SRC_URI:prepend = " \
    file://${BP}.tar.gz \
    file://fix-memleaks-in-asn1-arrat2tree.patch \
"

LIC_FILES_CHKSUM = "file://doc/COPYING;md5=d32239bcb673463ab874e80d47fae504 \
                    file://doc/COPYING.LESSER;md5=4fbd65380cdd255951079008b364516c \
                    file://COPYING;md5=75ac100ec923f959898182307970c360 \
"
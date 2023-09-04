# the main bb file: yocto-poky/meta/recipes-core/expat/expat_2.5.0.bb

OPENEULER_SRC_URI_REMOVE = "https git http"

LIC_FILES_CHKSUM = "file://COPYING;md5=7b3b078238d0901d3b339289117cb7fb"

PV = "2.5.0"

SRC_URI[sha256sum] = "6b902ab103843592be5e99504f846ec109c1abb692e85347587f237a4ffa1033"

# tar from openeuler
SRC_URI = " \
    file://expat-${PV}.tar.gz \
"


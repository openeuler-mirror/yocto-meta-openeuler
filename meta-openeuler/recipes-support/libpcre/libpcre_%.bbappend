# main bbfile: yocto-poky/meta/recipes-support/libpcre/libpcre_8.44.bb
#
OPENEULER_SRC_URI_REMOVE = "https git http"

# libpcre version in openeuler
PV = "8.45"

OPENEULER_REPO_NAME = "pcre"

# The MD5 valude of LICENCE file has been changed in this version
LIC_FILES_CHKSUM = "file://LICENCE;md5=b5d5d1a69a24ea2718263f1ff85a1c58"

# remove conflict files from poky
SRC_URI:remove = " \
        ${SOURCEFORGE_MIRROR}/pcre/pcre-${PV}.tar.bz2 \
"

# bb name is libpcre, but we want pcre in openeuler
SRC_URI:prepend = " \
        file://pcre-${PV}.tar.bz2 \
        "

SRC_URI[md5sum] = "4452288e6a0eefb2ab11d36010a1eebb"
SRC_URI[sha256sum] = "4dae6fdcd2bb0bb6c37b5f97c33c2be954da743985369cddac3546e3218bffb8"

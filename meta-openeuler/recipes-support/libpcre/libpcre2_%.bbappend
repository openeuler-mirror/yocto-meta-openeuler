# main bbfile: yocto-poky/meta/recipes-support/libpcre/libpcre2_10.36.bb

# version in openeuler
PV = "10.39"
LIC_FILES_CHKSUM = "file://LICENCE;md5=43cfa999260dd853cd6cb174dc396f3d"

OPENEULER_REPO_NAME = "pcre2"

# remove conflict files from poky
SRC_URI_remove = " \
        https://ftp.pcre.org/pub/pcre/pcre2-${PV}.tar.bz2 \
        https://github.com/PhilipHazel/pcre2/releases/download/pcre2-${PV}/pcre2-${PV}.tar.bz2 \
        "

#use openeuler source
SRC_URI_prepend += " \
        file://pcre2-${PV}.tar.bz2 \
        file://backport-pcre2-10.10-Fix-multilib.patch \
        file://backport-CVE-2022-1586-1.patch \
        file://backport-CVE-2022-1586-2.patch \
        file://backport-CVE-2022-1587.patch \
        "

SRC_URI[sha256sum] = "0f03caf57f81d9ff362ac28cd389c055ec2bf0678d277349a1a4bee00ad6d440"

# main bbfile: yocto-poky/meta/recipes-support/ca-certificates/ca-certificates_20210119.bb

# don't donwload ca-certificates by network
SRC_URI:remove = " \
        git://salsa.debian.org/debian/ca-certificates.git;protocol=https \
        git://salsa.debian.org/debian/ca-certificates.git;protocol=https;branch=master \
"

# get extra tarball locally, because ca-certificates src repository doesn't have ca-certificates.crt or tarball
FILESEXTRAPATHS:append := "${THISDIR}/files/:"
SRC_URI =+ " \
        file://${BP}.tar.gz \
"

SRC_URI[md5sum] = "94e83fc89f8e793dcb20939816c2011d"
SRC_URI[sha256sum] = "ad8db6bbea76741fe1108677bbddd2cab83f86427251703cabbdced6476e2113"

S = "${WORKDIR}/${BP}"

# main bbfile: yocto-poky/meta/recipes-support/ca-certificates/ca-certificates_20210119.bb

# don't donwload ca-certificates by network
SRC_URI_remove = " \
        git://salsa.debian.org/debian/ca-certificates.git;protocol=https \
"

# get extra config files from openeuler
FILESEXTRAPATHS_append := "${THISDIR}/files/:"
SRC_URI += " \
        file://${BP}.tar.gz;name=tarball \
"

SRC_URI[tarball.md5sum] = "8c582657fde36a021e6387019526b545"
SRC_URI[tarball.sha256sum] = "a639f1d0598fa8f7a864c7c93860bde2eb00c5a51e66c0f7b0e716f092852eaf"

S = "${WORKDIR}/${BP}"

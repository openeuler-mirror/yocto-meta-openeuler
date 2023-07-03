# main bbfile: yocto-poky/meta/recipes-extended/gzip/gzip_1.10.bb

OPENEULER_SRC_URI_REMOVE = "https git http"

# gzip version in openEuler
PV = "1.12"

# Use the source packages from openEuler
SRC_URI:remove = "${GNU_MIRROR}/gzip/${BP}.tar.gz"

SRC_URI:prepend = "file://${BP}.tar.xz \
           file://backport-gzip-detect-invalid-input.patch \
           file://backport-gzip-test-invalid-input-bug.patch \
           file://fix-verbose-disable.patch \
           "

SRC_URI[sha256sum] = "ce5e03e519f637e1f814011ace35c4f87b33c0bbabeec35baf5fbd3479e91956"

# main bbfile: yocto-poky/meta/recipes-extended/gzip/gzip_1.10.bb

OPENEULER_SRC_URI_REMOVE = "https git http"

# gzip version in openEuler
PV = "1.12"

# Use the source packages from openEuler
SRC_URI_remove = "${GNU_MIRROR}/gzip/${BP}.tar.gz"
SRC_URI_prepend += "file://${BP}.tar.xz \
    file://backport-gzip-detect-invalid-input.patch \
    file://backport-gzip-test-invalid-input-bug.patch \
    file://fix-verbose-disable.patch \
"

# remove poky's conflicting patch
SRC_URI_remove_class-target = " file://wrong-path-fix.patch"

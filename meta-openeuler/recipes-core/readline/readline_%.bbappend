# main bb file: yocto-poky/meta/recipes-core/readline/readline_8.1.bb
#
OPENEULER_SRC_URI_REMOVE = "https git http"

PV = "8.1"

# the patch is out of date, use openeuler patch
SRC_URI_remove = " \
        file://norpath.patch \
        "

SRC_URI_prepend = " \
        file://readline-${PV}.tar.gz \
        file://readline-8.0-shlib.patch \
"

SRC_URI[archive.md5sum] = "07fc9d33d6ab7e64778b0f27a3ed65ea"
SRC_URI[archive.sha256sum] = "ab9972cf45cdef5c7d5f9d773d6046013266389bb436bce8ab3b52fe02331f60"

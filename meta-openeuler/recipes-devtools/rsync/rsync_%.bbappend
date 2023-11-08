PV = "3.2.7"

OPENEULER_SRC_URI_REMOVE = "https"
SRC_URI:prepend = " \
        file://rsync-${PV}.tar.gz \
        "

# remove out-of-date patch
SRC_URI:remove = " \
        file://0001-Turn-on-pedantic-errors-at-the-end-of-configure.patch \
        file://0001-Add-missing-prototypes-to-function-declarations.patch \
        "

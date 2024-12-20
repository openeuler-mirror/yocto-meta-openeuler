PV = "3.2.7"

SRC_URI:prepend = " \
        file://${BP}.tar.gz \
        "

# remove out-of-date patch
SRC_URI:remove = " \
        file://0001-Turn-on-pedantic-errors-at-the-end-of-configure.patch \
        file://0001-Add-missing-prototypes-to-function-declarations.patch \
        file://backport-Fix-overflow-of-sum2-buffer-for-sha1-rolling-checksu.patch \
        file://backport-Duplicate-argv-data-before-poptFreeContext.patch \
        "

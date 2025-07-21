PV = "0.7.0"
require pypi-src-openeuler.inc

# apply openeuler's patches
SRC_URI:append = " \
        file://Fix-handling-missing-hypothesmith-gracefully.patch \
        "

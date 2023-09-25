# main bbfile: yocto-meta-openembedded/meta-oe/recipes-support/gflags/gflags_2.2.2.bb

OPENEULER_SRC_URI_REMOVE = "https git"
OPENEULER_REPO_NAME = "gflags"

# version in openEuler
PV = "2.2.2"
S = "${WORKDIR}/gflags-${PV}"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI:remove = " \
"

# files, patches that come from openeuler
SRC_URI:prepend = " \
    file://gflags-${PV}.tar.gz \
"


# main bb: ref openembedded-core rng-tools 6.11
#
OPENEULER_SRC_URI_REMOVE = "https git http"

# version in openEuler
PV = "6.14"

SRC_URI_prepend = "\
    file://v${PV}.tar.gz \
"

# change source directory
S = "${WORKDIR}/${BP}"

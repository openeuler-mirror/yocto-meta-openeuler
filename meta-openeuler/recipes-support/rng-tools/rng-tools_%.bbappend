#main bb: ref openembedded-core rng-tools 6.16
#
OPENEULER_SRC_URI_REMOVE = "https git http"

# version in openEuler
PV = "6.16"

# remove git protocol
SRC_URI:remove = "\
"

SRC_URI:prepend = "\
    file://v${PV}.tar.gz \
"

# change source directory
S = "${WORKDIR}/${BP}"

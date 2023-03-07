#main bb: ref openembedded-core rng-tools 6.16
#
OPENEULER_SRC_URI_REMOVE = "https git http"
OPENEULER_BRANCH = "openEuler-23.03"

# version in openEuler
PV = "6.16"

# remove git protocol
SRC_URI_remove = "\
"

SRC_URI_prepend = "\
    file://v${PV}.tar.gz \
"

# change source directory
S = "${WORKDIR}/${BP}"

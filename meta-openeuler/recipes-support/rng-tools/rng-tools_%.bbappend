#main bb: ref openembedded-core rng-tools 6.16
#

# version in openEuler
PV = "6.16"

SRC_URI:prepend = "\
    file://v${PV}.tar.gz \
"

# change source directory
S = "${WORKDIR}/${BP}"

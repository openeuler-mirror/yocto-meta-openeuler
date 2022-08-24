# version in openEuler
PV = "6.14"

# remove git protocol
SRC_URI_remove = "\
    git://github.com/nhorman/rng-tools.git \
    git://github.com/nhorman/rng-tools.git;branch=master;protocol=https \
"

SRC_URI_prepend = "\
    file://rng-tools/v${PV}.tar.gz \
"

# change source directory
S = "${WORKDIR}/${BP}"

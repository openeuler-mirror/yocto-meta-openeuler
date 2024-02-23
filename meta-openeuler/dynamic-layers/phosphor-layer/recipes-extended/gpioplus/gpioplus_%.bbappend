
# we do not use git to download the source code
# so the variable ${SRCPV} is not set
# remove this variable from ${PV}
PV = "0.1"

SRC_URI += " \
    file://${BPN} \
"

# the source code repository fetched by openeuler_fetch
S = "${WORKDIR}/${BPN}"
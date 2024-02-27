# we fetch the source code through openeuler_fetch.
# Thus, there are some common configurations needed to be changed.
include phosphor-inventory-manager-src.inc
# we do not use git to download the source code
# so the variable ${SRCPV} is not set
# remove this variable from ${PV}
PV = "1.0"

# the source code repository fetched by openeuler_fetch
S = "${WORKDIR}/${OPENEULER_LOCAL_NAME}"

# we do not use git to download the source code
# so the variable ${SRCPV} is not set
# remove this variable from ${PV}
PV = "1.0"

SRC_URI += " \
    file://phosphor-objmgr \
"

# the source code repository fetched by openeuler_fetch
S = "${WORKDIR}/phosphor-objmgr"

# many software packages use the same repository as the source code,
# the local name maybe different from the ${BPN}
# so we need to set the local name explicitly
OPENEULER_LOCAL_NAME = "phosphor-objmgr"

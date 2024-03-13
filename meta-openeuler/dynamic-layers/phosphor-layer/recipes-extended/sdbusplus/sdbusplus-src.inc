# we do not use git to download the source code
# so the variable ${SRCPV} is not set
# remove this variable from ${PV}
PV = "1.0"

# the source code repository fetched by openeuler_fetch
SRC_URI += "file://sdbusplus"

# many software packages use sdbusplus as the source code,
# the local name maybe different from the ${BPN}
# so we need to set the local name explicitly
OPENEULER_LOCAL_NAME = "sdbusplus"

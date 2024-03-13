
# we do not use git to download the source code
# so the variable ${SRCPV} is not set
# remove this variable from ${PV}
PV = "1.0"

SRC_URI += " \
    file://phosphor-dbus-interfaces \
"

# the source code repository fetched by openeuler_fetch
S = "${WORKDIR}/${BPN}"

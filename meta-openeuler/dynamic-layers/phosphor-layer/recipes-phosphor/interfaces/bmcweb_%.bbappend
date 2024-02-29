
# we do not use git to download the source code
# so the variable ${SRCPV} is not set
# remove this variable from ${PV}
PV = "1.0"

SRC_URI += " \
    file://${BPN} \
"

# the source code repository fetched by openeuler_fetch
S = "${WORKDIR}/${BPN}"

# upgrade to latter version to resolve boost compilation issue
# DEPENDS:remove = "boost-url"
# GROUPADD_PARAM:${PN}:append = "; hostconsole"

# EXTRA_OEMESON:remove = " -Dyocto-deps=enabled"

# DEPENDS += "nghttp2"
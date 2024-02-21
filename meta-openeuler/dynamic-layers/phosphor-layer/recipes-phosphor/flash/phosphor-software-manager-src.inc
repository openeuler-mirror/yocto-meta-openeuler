
# the source code repository fetched by openeuler_fetch
SRC_URI += "file://phosphor-bmc-code-mgmt"

# many software packages use the same repository as the source code,
# the local name maybe different from the ${BPN}
# so we need to set the local name explicitly
OPENEULER_LOCAL_NAME = "phosphor-bmc-code-mgmt"

OPENEULER_SRC_URI_REMOVE = "https git http"

# version in openEuler
PV = "8.8p1"

FILESEXTRAPATHS_prepend := "${THISDIR}/openeuler-config/:"

# poky patches conflict with openeuler
SRC_URI_remove = " \
        file://CVE-2021-41617.patch \
        "

SRC_URI_prepend = " \
        file://openssh-${PV}.tar.gz \
        "

# checksum changed
SRC_URI[sha256sum] = "4590890ea9bb9ace4f71ae331785a3a5823232435161960ed5fc86588f331fe9"

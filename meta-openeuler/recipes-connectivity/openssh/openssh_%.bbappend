# version in openEuler
PV = "8.8p1"

FILESEXTRAPATHS_prepend := "${THISDIR}/openssh/:"

# poky patches conflict with openeuler
SRC_URI_remove += " \
        file://CVE-2021-41617.patch \
        "

# checksum changed
SRC_URI[sha256sum] = "4590890ea9bb9ace4f71ae331785a3a5823232435161960ed5fc86588f331fe9"

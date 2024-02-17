OPENEULER_REPO_NAME = "yocto-opkg-utils"

# version in openEuler
PV = "0.5.0"

# add openeuler local package
SRC_URI:prepend = "file://opkg-utils-${PV}.tar.gz \
"

SRC_URI[sha256sum] = "55733c0f8ffde2bb4f9593cfd66a1f68e6a2f814e8e62f6fd78472911c818c32"

S = "${WORKDIR}/opkg-utils-${PV}"

# currently, openeuler_embedded only supports update-alternatives, no python
PACKAGECONFIG:remove = "${@['', 'python']['${OPENEULER_PREBUILT_TOOLS_ENABLE}' == 'yes']}"

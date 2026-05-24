OPENEULER_LOCAL_NAME = "yocto-opkg-utils"

# version in openEuler
PV = "0.5.0"

# add openeuler local package
SRC_URI:prepend = "file://${BP}.tar.gz \
"

# patches from scarthgap recipe (0.6.3) that don't apply to 0.5.0 source
SRC_URI:remove = " \
        file://0001-opkg-build-remove-numeric-owner-parameter-overzealou.patch \
        file://0001-update-alternatives-correctly-match-priority.patch \
"

SRC_URI[sha256sum] = "55733c0f8ffde2bb4f9593cfd66a1f68e6a2f814e8e62f6fd78472911c818c32"

S = "${WORKDIR}/${BP}"

# currently, openeuler_embedded only supports update-alternatives, no python
PACKAGECONFIG:remove = "${@['', 'python']['${OPENEULER_PREBUILT_TOOLS_ENABLE}' == 'yes']}"

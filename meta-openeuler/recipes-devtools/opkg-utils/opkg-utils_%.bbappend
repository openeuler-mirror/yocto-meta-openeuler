# acl version in openEuler
PV = "0.5.0"

OPENEULER_REPO_NAME = "yocto-opkg-utils"

# currently, openeuler_embedded only supports update-alternatives, no python
PACKAGECONFIG = "update-alternatives"

# remove upstream url and patch, the patch can not apply
SRC_URI:remove = "git://git.yoctoproject.org/opkg-utils;protocol=https;branch=master \
"

S = "${WORKDIR}/opkg-utils-${PV}"

# add openeuler local package
SRC_URI:prepend = "file://opkg-utils-${PV}.tar.gz \
"

SRC_URI[md5sum] = "c71939ee02c69462bd3ba1fe0d6de5e2"
SRC_URI[sha256sum] = "55733c0f8ffde2bb4f9593cfd66a1f68e6a2f814e8e62f6fd78472911c818c32"

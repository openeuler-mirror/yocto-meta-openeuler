# main bbfile: yocto-poky/meta/recipes-support/liburcu_0.13.2.bb

# version in openEuler
PV = "0.13.2"

OPENEULER_REPO_NAME = "userspace-rcu"

SRC_URI:prepend = "file://userspace-rcu-${PV}.tar.bz2 \
"

SRC_URI[md5sum] = "e76e7f8ddce0f229cbd870e7ff39193e"
SRC_URI[sha256sum] = "1213fd9f1b0b74da7de2bb74335b76098db9738fec5d3cdc07c0c524f34fc032"

S = "${WORKDIR}/${OPENEULER_REPO_NAME}-${PV}"

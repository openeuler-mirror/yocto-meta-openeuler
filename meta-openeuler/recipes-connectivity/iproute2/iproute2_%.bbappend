# the main bb file: yocto-poky/meta/recipes-connectivity/iproute2/iproute2_5.17.0.bb

PV = "6.4.0"
OPENEULER_REPO_NAME = "iproute"

LIC_FILES_CHKSUM = "file://COPYING;md5=eb723b61539feef013de476e68b5c50a"

SRC_URI:remove = "${KERNELORG_MIRROR}/linux/utils/net/${BPN}/${BP}.tar.xz"

SRC_URI:append = " \
        file://${BPN}-${PV}.tar.xz \
        file://bugfix-iproute2-3.10.0-fix-maddr-show.patch  \
        file://bugfix-iproute2-change-proc-to-ipnetnsproc-which-is-private.patch \
        file://feature-iproute-add-support-for-ipvlan-l2e-mode.patch \
        file://bugfix-iproute2-cancel-some-test-cases.patch \
"

SRC_URI[sha256sum] = "4c51b8decbc7e4da159ffb066f590cfb93dbf9af7ff86b1647ce42b7c179a272"

EXTRA_OEMAKE:append = " CCOPTS='${CFLAGS}' \
"
PACKAGECONFIG[selinux] = ",,libselinux"

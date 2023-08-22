SUMMARY = "packages for iSulad"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

PR = "r1"

PACKAGES = "${PN}"

RDEPENDS:${PN} = " \
libseccomp \
libwebsockets \
yajl \
lcr \
lxc \
libevhtp \
libarchive \
libevent \
isulad \
${@bb.utils.contains('INIT_MANAGER', 'systemd', 'lxcfs', '', d)} \
"

SUMMARY = "packages for iSulad"
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

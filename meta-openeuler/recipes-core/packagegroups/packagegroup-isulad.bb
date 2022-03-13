SUMMARY = "packages for iSulad"
inherit packagegroup

PR = "r1"

PACKAGES = "${PN}"

RDEPENDS_${PN} = "\
libseccomp \
libwebsockets \
yajl \
lcr \
lxc \
libevhtp \
libarchive \
libevent \
iSulad \
    "

HOMEPAGE = "https://github.com/containerd/containerd"
SRCREV = "2bf793ef6dc9a18e00cb12efb64355c2c9d5eb41"
CONTAINERD_VERSION = "v1.7.19"
CVE_VERSION = "1.7.19"
PV = "${CONTAINERD_VERSION}+git"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:remove = "git://github.com/containerd/containerd;branch=release/1.6;protocol=https;destsuffix=git/src/github.com/containerd/containerd"
SRC_URI:append = "git://github.com/containerd/containerd;branch=release/1.7;protocol=https;destsuffix=git/src/github.com/containerd/containerd \
"
#EXTRA_OEMAKE:append:pn-containerd-opencontainers = " GO111MODULE=on GO_BUILD_FLAGS+=-mod=vendor"

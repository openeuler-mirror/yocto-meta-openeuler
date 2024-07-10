# tag: RELEASE-4.18.0
SRCREV ?= "01f7a3c792241d348a4e454a30afdf6c0d6cd71c"

XEN_REL ?= "4.18.2"
XEN_BRANCH ?= "stable-4.18"

SRC_URI = " \
    git://xenbits.xen.org/xen.git;branch=${XEN_BRANCH} \
    file://0001-menuconfig-mconf-cfg-Allow-specification-of-ncurses-location.patch \
    file://0001-arm-silence-gcc14-warning-error-on-irq-bounds-check.patch \
    "

LIC_FILES_CHKSUM ?= "file://COPYING;md5=d1a1e216f80b6d8da95fec897d0dbec9"

PV = "${XEN_REL}+stable"

S = "${WORKDIR}/git"

DEFAULT_PREFERENCE ??= "-1"

require xen.inc
require xen-hypervisor.inc

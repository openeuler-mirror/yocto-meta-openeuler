# main bb: yocto-poky/meta/recipes-support/libcap-ng/libcap-ng_0.8.2.bb
OPENEULER_SRC_URI_REMOVE = "https git"

PV = "0.8.3"

# determinism.patch no need for 0.8.3
SRC_URI:remove = "file://determinism.patch"

SRC_URI:append = " \
        file://libcap-ng-${PV}.tar.gz \
        file://backport-Make-Python-test-script-compatible-with-Python2-and-Python3.patch \
        "

S = "${WORKDIR}/libcap-ng-${PV}"

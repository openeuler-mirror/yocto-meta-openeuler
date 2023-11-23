# main bb file: yocto-poky/meta/recipes-connectivity/libuv/libuv_1.41.0.bb

OPENEULER_SRC_URI_REMOVE = "git"

# version in openEuler
PV = "1.42.0"

# apply openEuler source package
SRC_URI_prepend = "file://${BPN}-v${PV}.tar.gz \
                file://libuv-Add-sw64-architecture.patch \
                file://backport-Skip-some-tests.patch \
                file://0001-test-fix-typo-in-test-tty-escape-sequence-processing.patch \
"

S = "${WORKDIR}/${BPN}-v${PV}"

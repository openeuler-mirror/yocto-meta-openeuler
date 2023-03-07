PV = "6.1.0"
OPENEULER_REPO_NAME = "iproute"

OPENEULER_SRC_URI_REMOVE = "https git http"
SRC_URI += " \
        file://${BPN}-${PV}.tar.xz \
        file://bugfix-iproute2-3.10.0-fix-maddr-show.patch \
        file://bugfix-iproute2-change-proc-to-ipnetnsproc-which-is-private.patch \
        file://backport-testsuite-fix-testsuite-build-failure-when-iproute-b.patch \
        file://feature-iproute-add-support-for-ipvlan-l2e-mode.patch \
        file://bugfix-iproute2-cancel-some-test-cases.patch \
"

SRC_URI[sha256sum] = "5ce12a0fec6b212725ef218735941b2dab76244db7e72646a76021b0537b43ab"

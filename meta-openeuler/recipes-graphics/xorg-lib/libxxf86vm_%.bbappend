require openeuler-xorg-lib-common.inc

PV = "1.1.5"
# patches from openEuler
SRC_URI:append = "file://backport-configure-Use-LT_INIT-from-libtool-2-instead-of-depr.patch \
"
SRC_URI[sha256sum] = "f3f1c29fef8accb0adbd854900c03c6c42f1804f2bc1e4f3ad7b2e1f3b878128"

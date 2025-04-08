# main bbfile: yocto-poky/meta/recipes-support/popt/popt_1.18.bb

PV = "1.19"

SRC_URI:remove = " \
		file://0001-popt-test-output-format-for-ptest.patch \
"

SRC_URI:prepend = "file://${BP}.tar.gz \
		file://fix-obscure-iconv-mis-call-error-path-could-lead-to-.patch \
		file://fix-handle-newly-added-asset-.-call-like-elsewhere.patch \
		file://fix-permit-reading-aliases-remove-left-over-goto-exi.patch \
		file://fix-coverity-CID-1057440-Unused-pointer-value-UNUSED.patch \
        file://revert-fix-memory-leak-regressions-in-popt.patch \
"

SRC_URI[md5sum] = "eaa2135fddb6eb03f2c87ee1823e5a78"
SRC_URI[sha256sum] = "bef3de159bcd61adf98bb7cc87ee9046e944644ad76b7633f18ab063edb29e57"
LIC_FILES_CHKSUM = "file://COPYING;md5=e0206ac9471d06667e076212db20c5f4"

ASSUME_PROVIDE_PKGS = "popt"

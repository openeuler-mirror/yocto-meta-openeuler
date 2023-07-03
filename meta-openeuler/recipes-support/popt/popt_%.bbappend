# main bbfile: yocto-poky/meta/recipes-support/popt/popt_1.18.bb

PV = "1.19"

SRC_URI:remove = "http://ftp.rpm.org/popt/releases/popt-1.x/${BP}.tar.gz \
		file://0001-popt-test-output-format-for-ptest.patch \
"

SRC_URI:prepend = "file://${BPN}-${PV}.tar.gz \
		file://fix-obscure-iconv-mis-call-error-path-could-lead-to-.patch \
		file://fix-handle-newly-added-asset-.-call-like-elsewhere.patch \
		file://fix-permit-reading-aliases-remove-left-over-goto-exi.patch \
		file://fix-coverity-CID-1057440-Unused-pointer-value-UNUSED.patch \
        file://revert-fix-memory-leak-regressions-in-popt.patch \
"

SRC_URI[md5sum] = "eaa2135fddb6eb03f2c87ee1823e5a78"
SRC_URI[sha256sum] = "c25a4838fc8e4c1c8aacb8bd620edb3084a3d63bf8987fdad3ca2758c63240f9"
LIC_FILES_CHKSUM = "file://COPYING;md5=e0206ac9471d06667e076212db20c5f4"

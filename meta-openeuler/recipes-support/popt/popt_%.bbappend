# main bbfile: yocto-poky/meta/recipes-support/popt/popt_1.18.bb
PV = "1.18"

# files, patches that come from openeuler
OPENEULER_SRC_URI_REMOVE = "https git http"
SRC_URI += " \
	file://${BPN}-${PV}.tar.gz \
	file://fix-obscure-iconv-mis-call-error-path-could-lead-to-.patch \
	file://fix-handle-newly-added-asset-.-call-like-elsewhere.patch \
	file://fix-permit-reading-aliases-remove-left-over-goto-exi.patch \
	file://fix-coverity-CID-1057440-Unused-pointer-value-UNUSED.patch \
	file://backport-Consider-POPT_CONTEXT_KEEP_FIRST-during-reset.patch \
	file://backport-Fix-incorrect-handling-of-leftovers-with-poptStuffAr.patch \
"

SRC_URI[md5sum] = "450f2f636e6a3aa527de803d0ae76c5a"
SRC_URI[sha256sum] = "5159bc03a20b28ce363aa96765f37df99ea4d8850b1ece17d1e6ad5c24fdc5d1"

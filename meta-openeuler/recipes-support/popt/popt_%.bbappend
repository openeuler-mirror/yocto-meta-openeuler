# main bbfile: yocto-poky/meta/recipes-support/popt/popt_1.18.bb

# files, patches that come from openeuler
SRC_URI += " \
	file://fix-obscure-iconv-mis-call-error-path-could-lead-to-.patch \
	file://fix-handle-newly-added-asset-.-call-like-elsewhere.patch \
	file://fix-permit-reading-aliases-remove-left-over-goto-exi.patch \
	file://fix-coverity-CID-1057440-Unused-pointer-value-UNUSED.patch \
	file://backport-Consider-POPT_CONTEXT_KEEP_FIRST-during-reset.patch \
	file://backport-Fix-incorrect-handling-of-leftovers-with-poptStuffAr.patch \
"

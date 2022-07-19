# main bbfile: yocto-poky/meta/recipes-support/popt/popt_1.18.bb

# files, patches that come from openeuler
SRC_URI += " \
	file://popt/fix-coverity-CID-1057440-Unused-pointer-value-UNUSED.patch \
	file://popt/fix-handle-newly-added-asset-.-call-like-elsewhere.patch \
	file://popt/fix-obscure-iconv-mis-call-error-path-could-lead-to-.patch \
	file://popt/fix-permit-reading-aliases-remove-left-over-goto-exi.patch \
"

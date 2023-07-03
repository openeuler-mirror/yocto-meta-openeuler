# main bbfile: yocto-poky/meta/recipes-support/libpcre/libpcre2_10.36.bb

# version in openeuler
PV = "10.40"
LIC_FILES_CHKSUM = "file://LICENCE;md5=41bfb977e4933c506588724ce69bf5d2"

OPENEULER_REPO_NAME = "pcre2"

# use openeuler source
SRC_URI:prepend = "file://backport-pcre2-10.10-Fix-multilib.patch \
           file://backport-doc-avoid-nonexistent-PCRE2_ERROR_MEMORY-error-107.patch \
           file://backport-Update-HTML-docs.patch \
           file://backport-Fixed-race-condition-that-occurs-when-initializing-t.patch \
           file://backport-Change-length-variables-in-pcre2grep-from-int-to-siz.patch \
           file://backport-Add-an-ifdef-to-avoid-the-need-even-to-link-with-pcr.patch \
           file://backport-Fixed-an-issue-in-the-backtracking-optimization-of-c.patch \
"

SRC_URI[sha256sum] = "14e4b83c4783933dc17e964318e6324f7cae1bc75d8f3c79bc6969f00c159d68"

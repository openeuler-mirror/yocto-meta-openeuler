# main bbfile: yocto-poky/meta/recipes-support/libpcre/libpcre2_10.36.bb

OPENEULER_REPO_NAME = "pcre2"

# version in openeuler
PV = "10.39"
LIC_FILES_CHKSUM = "file://LICENCE;md5=43cfa999260dd853cd6cb174dc396f3d"

# remove conflict files from poky
SRC_URI_remove = " \
        https://ftp.pcre.org/pub/pcre/pcre2-${PV}.tar.bz2 \
        https://github.com/PhilipHazel/pcre2/releases/download/pcre2-${PV}/pcre2-${PV}.tar.bz2 \
        "

#use openeuler source
SRC_URI_prepend += " \
        file://pcre2-${PV}.tar.bz2 \
        file://backport-pcre2-10.10-Fix-multilib.patch \
        file://backport-CVE-2022-1586-1.patch \
        file://backport-CVE-2022-1586-2.patch \
        file://backport-CVE-2022-1587.patch \
        file://backport-Add-an-ifdef-to-avoid-the-need-even-to-link-with-pcr.patch \
        file://backport-Change-length-variables-in-pcre2grep-from-int-to-siz.patch \
        file://backport-Fix-recursion-issue-in-JIT.patch \
        file://backport-Fixed-an-issue-in-the-backtracking-optimization-of-c.patch \
        file://backport-Fixed-race-condition-that-occurs-when-initializing-t.patch \
        file://backport-Revert-an-unintended-change-in-JIT-repeat-detection.patch \
        file://backport-Update-HTML-docs.patch \
        file://backport-doc-avoid-nonexistent-PCRE2_ERROR_MEMORY-error-107.patch \
        file://backport-jit-avoid-integer-wraparound-in-stack-size-definitio.patch \
        file://backport-jit-use-correct-type-when-checking-for-max-value-73.patch \
        file://backport-match-avoid-crash-if-subject-NULL-and-PCRE2_ZERO_TER.patch \
        file://backport-pcre2grep-correctly-handle-multiple-passes-35.patch \
        "

SRC_URI[sha256sum] = "0f03caf57f81d9ff362ac28cd389c055ec2bf0678d277349a1a4bee00ad6d440"

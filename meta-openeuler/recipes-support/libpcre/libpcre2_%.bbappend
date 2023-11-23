# main bbfile: yocto-poky/meta/recipes-support/libpcre/libpcre2_10.36.bb
OPENEULER_SRC_URI_REMOVE = "https"

# version in openeuler
PV = "10.39"
LIC_FILES_CHKSUM = "file://LICENCE;md5=43cfa999260dd853cd6cb174dc396f3d"

OPENEULER_REPO_NAME = "pcre2"

# use openeuler source
SRC_URI_prepend = " \
                file://pcre2-${PV}.tar.bz2 \
                file://backport-pcre2-10.10-Fix-multilib.patch \
                file://backport-CVE-2022-1586-1.patch \
                file://backport-CVE-2022-1586-2.patch \
                file://backport-CVE-2022-1587.patch \
                file://backport-pcre2grep-correctly-handle-multiple-passes-35.patch \
                file://backport-jit-avoid-integer-wraparound-in-stack-size-definitio.patch \
                file://backport-Revert-an-unintended-change-in-JIT-repeat-detection.patch \
                file://backport-match-avoid-crash-if-subject-NULL-and-PCRE2_ZERO_TER.patch \
                file://backport-jit-use-correct-type-when-checking-for-max-value-73.patch \
                file://backport-Fix-recursion-issue-in-JIT.patch \
                file://backport-doc-avoid-nonexistent-PCRE2_ERROR_MEMORY-error-107.patch \
                file://backport-Update-HTML-docs.patch \
                file://backport-Fixed-race-condition-that-occurs-when-initializing-t.patch \
                file://backport-Change-length-variables-in-pcre2grep-from-int-to-siz.patch \
                file://backport-Add-an-ifdef-to-avoid-the-need-even-to-link-with-pcr.patch \
                file://backport-Fixed-an-issue-in-the-backtracking-optimization-of-c.patch \
                file://backport-jit-fail-early-in-ffcps_-if-subject-shorter-than-off.patch \
                file://backport-jit-fix-pcre2_jit_free_unused_memory-if-sljit-not-us.patch \
                file://backport-pcre2grep-document-better-possible-multiline-matchin.patch \
                file://backport-no-partial-match-if-trailing-data-is-invalid-utf-238.patch \
                file://backport-Fix-an-invalid-match-of-ascii-word-classes-when-inva.patch \
                file://backport-fix-wrong-test.patch \
                file://backport-fix-CVE-2022-41409.patch \
        "

SRC_URI[sha256sum] = "0f03caf57f81d9ff362ac28cd389c055ec2bf0678d277349a1a4bee00ad6d440"


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
                file://backport-fix-a-possible-integer-overflow-in-DFA-matching-305.patch \
                file://backport-Fix-oversight-in-DFA-when-changing-OP_REVERSE-also-a.patch \
                file://backport-Fix-32-bit-quantifier-following-a-character-larger-t.patch \
                file://backport-Fix-z-behaviour-when-matching-within-invalid-UTF.patch \
                file://backport-Fix-incorrect-patch-in-c1306126.patch \
                file://backport-Fix-another-oversight-in-c1306126.patch \
                file://backport-Fix-X-matching-in-32-bit-mode-without-UTF-in-JIT.patch \
                file://backport-Fix-bad-patch-in-05206d66.-The-interpreter-was-handl.patch \
                file://backport-Fix-backref-iterators-when-PCRE2_MATCH_UNSET_BACKREF.patch \
                file://backport-Fix-compile-loop-in-32-bit-mode-for-characters-above.patch \
                file://backport-Fix-incorrect-matching-of-0xffffffff-to-any-characte.patch \
                file://backport-Fix-accept-and-endanchored-interaction-in-JIT.patch \
                file://backport-Fix-backreferences-with-unset-backref-and-non-greedy.patch \
                file://backport-Sanity-checks-for-ctype-functions-342.patch \
                file://backport-Fix-incorrect-class-character-matches-in-JIT.patch \
                file://backport-Fixing-an-issue-using-empty-character-sets-in-jit.patch \
"

SRC_URI[sha256sum] = "0f03caf57f81d9ff362ac28cd389c055ec2bf0678d277349a1a4bee00ad6d440"


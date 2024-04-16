# main bbfile: yocto-poky/meta/recipes-support/libpcre/libpcre2_10.36.bb

# version in openeuler
PV = "10.42"
LIC_FILES_CHKSUM = "file://LICENCE;md5=41bfb977e4933c506588724ce69bf5d2"

OPENEULER_REPO_NAME = "pcre2"

# use openeuler source
SRC_URI:prepend = "file://pcre2-${PV}.tar.bz2 \
            file://backport-pcre2-10.10-Fix-multilib.patch \
            file://backport-no-partial-match-if-trailing-data-is-invalid-utf-238.patch \
            file://backport-Fix-an-invalid-match-of-ascii-word-classes-when-inva.patch \
            file://backport-fix-wrong-test.patch \
            file://sljit-sv48-sv57.patch \
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
"

SRC_URI[sha256sum] = "8d36cd8cb6ea2a4c2bb358ff6411b0c788633a2a45dabbf1aeb4b701d1b5e840"

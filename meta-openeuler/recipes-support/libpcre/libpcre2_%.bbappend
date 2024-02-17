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
"

SRC_URI[sha256sum] = "8d36cd8cb6ea2a4c2bb358ff6411b0c788633a2a45dabbf1aeb4b701d1b5e840"

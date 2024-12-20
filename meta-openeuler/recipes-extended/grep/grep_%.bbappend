
PV = "3.11"

# sync openeuler's grep to use pcre2
PACKAGECONFIG:append = " pcre2"
PACKAGECONFIG:remove = "pcre"
PACKAGECONFIG[pcre2] = "--enable-perl-regexp,--disable-perl-regexp,libpcre2"

# remove outdated patch
SRC_URI:remove = "file://0001-mcontext-is-not-a-standard-layout-so-glibc-and-musl-.patch"

SRC_URI:prepend = " \
    file://${BP}.tar.xz \
    file://fix-grep-m2-pattern.patch \
    file://backport-Fix-troff-typos-found-by-mandoc-and-groff.patch \
    file://backport-Fix-recognition-of-cs_CZ.UTF-8-locale-on-FreeBSD.patch \
"

SRC_URI[sha256sum] = "498d7cc1b4fb081904d87343febb73475cf771e424fb7e6141aff66013abc382"

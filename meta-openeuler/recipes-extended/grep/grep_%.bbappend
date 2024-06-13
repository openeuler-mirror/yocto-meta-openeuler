OPENEULER_SRC_URI_REMOVE = "https git http"

PV = "3.7"

# sync openeuler's grep to use pcre2
PACKAGECONFIG:append = " pcre2"
PACKAGECONFIG:remove = "pcre"
PACKAGECONFIG[pcre2] = "--enable-perl-regexp,--disable-perl-regexp,libpcre2"

SRC_URI += " \
    file://grep-${PV}.tar.xz \
    file://backport-grep-avoid-sticky-problem-with-f-f.patch \
    file://backport-grep-s-does-not-suppress-binary-file-matches.patch \
    file://backport-grep-bug-backref-in-last-of-multiple-patter.patch \
    file://backport-fix-regex-compilation-memory-leaks.patch \
    file://backport-grep-work-around-PCRE-bug.patch \
    file://backport-grep-migrate-to-pcre2.patch \
    file://backport-grep-Don-t-limit-jitstack_max-to-INT_MAX.patch \
    file://backport-grep-speed-up-fix-bad-UTF8-check-with-P.patch \
    file://backport-grep-fix-minor-P-memory-leak.patch \
    file://backport-pcre-use-UCP-in-UTF-mode.patch \
"

SRC_URI[sha256sum] = "498d7cc1b4fb081904d87343febb73475cf771e424fb7e6141aff66013abc382"

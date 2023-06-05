OPENEULER_SRC_URI_REMOVE = "https git http"

PV = "3.7"

SRC_URI += " \
    file://grep-${PV}.tar.xz \
    file://backport-grep-avoid-sticky-problem-with-f-f.patch \
    file://backport-grep-s-does-not-suppress-binary-file-matches.patch \
    file://backport-grep-bug-backref-in-last-of-multiple-patter.patch \
    file://backport-pcre-use-UCP-in-UTF-mode.patch \
"

SRC_URI[sha256sum] = "498d7cc1b4fb081904d87343febb73475cf771e424fb7e6141aff66013abc382"

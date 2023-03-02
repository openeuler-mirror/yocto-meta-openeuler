OPENEULER_SRC_URI_REMOVE = "https git http"
OPENEULER_BRANCH = "openEuler-23.03"

PV = "3.8"

# sync openeuler's grep to use pcre2
PACKAGECONFIG_append += "pcre2"
PACKAGECONFIG_remove += "pcre"
PACKAGECONFIG[pcre2] = "--enable-perl-regexp,--disable-perl-regexp,libpcre2"

SRC_URI += " \
    file://grep-${PV}.tar.xz \
    file://backport-grep-bug-backref-in-last-of-multiple-patter.patch \
"

SRC_URI[sha256sum] = "498d7cc1b4fb081904d87343febb73475cf771e424fb7e6141aff66013abc382"

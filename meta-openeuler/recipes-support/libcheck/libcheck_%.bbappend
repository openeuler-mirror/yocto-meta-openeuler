# bbfile: yocto-poky/meta/recipes-support/libcheck/libcheck_0.15.2.bb

OPENEULER_SRC_URI_REMOVE = "https"

PV = "0.15.2"

OPENEULER_REPO_NAME = "check"

SRC_URI_prepend = "file://check-${PV}.tar.gz \
        file://check-0.11.0-fp.patch \
        file://check-0.11.0-info-in-builddir.patch \
"

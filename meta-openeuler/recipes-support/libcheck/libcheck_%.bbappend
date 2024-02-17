PV = "0.15.2"
OPENEULER_REPO_NAME = "check"
SRC_URI:prepend = "file://check-${PV}.tar.gz \
                   file://check-0.11.0-fp.patch \
                   file://check-0.11.0-info-in-builddir.patch \
"

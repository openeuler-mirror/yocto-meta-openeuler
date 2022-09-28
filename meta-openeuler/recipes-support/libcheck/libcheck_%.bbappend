PV = "0.15.2"
OPENEULER_REPO_NAME = "check"
SRC_URI_remove = "https://github.com/${BPN}/check/releases/download/${PV}/check-${PV}.tar.gz \"
SRC_URI_prepend = "file://check-${PV}.tar.gz \
                   file://check-0.11.0-fp.patch \
                   file://check-0.11.0-info-in-builddir.patch \
"

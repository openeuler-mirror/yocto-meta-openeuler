OPENEULER_REPO_NAME = "mesa"

PV = "23.3.1"

SRC_URI:prepend = "file://mesa-${PV}.tar.xz \
           file://backport-fix-build-err-on-arm.patch \
           "


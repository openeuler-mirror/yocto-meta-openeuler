OPENEULER_REPO_NAME = "gstreamer1"

PV = "1.20.4"

SRC_URI:prepend = " \
        file://gstreamer-${PV}.tar.xz \
        file://ci.patch \
        file://gstreamer-inspect-rpm-format.patch \
        "

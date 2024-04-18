OPENEULER_REPO_NAME = "gstreamer1"

PV = "1.22.5"

SRC_URI:prepend = " \
        file://gstreamer-${PV}.tar.xz \
"

# patches from openEuler
SRC_URI:append = " \
        file://gstreamer-inspect-rpm-format.patch \
"

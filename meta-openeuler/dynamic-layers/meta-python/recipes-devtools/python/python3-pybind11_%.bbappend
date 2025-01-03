PV = "2.11.1"
SRC_URI[md5sum] = "06d173fb97f1d2d804d318e47f924892"
SRC_URI[sha256sum] = "f1bcc07caa568eb312411dde5308b1e250bd0e1bc020fae855bf9f43209940cc"

# remove meta-python conflict src
SRC_URI:remove = " \
        file://0001-Do-not-strip-binaries.patch \
        file://0001-Do-not-check-pointer-size-when-cross-compiling.patch \
"

S = "${WORKDIR}/pybind11-${PV}"
OPENEULER_LOCAL_NAME = "pybind11"

SRC_URI:prepend = "file://pybind11-${PV}.tar.gz "

PV = "2.10.0"
SRC_URI[md5sum] = "da561ebf81594930d368a9f9aae0d035"
SRC_URI[sha256sum] = "eacf582fa8f696227988d08cfc46121770823839fe9e301a20fbce67e7cd70ec"

# remove meta-python conflict src
SRC_URI_remove += " \
        git://github.com/pybind/pybind11.git;branch=master;protocol=https \
        file://0001-Do-not-strip-binaries.patch \
        file://0001-Do-not-check-pointer-size-when-cross-compiling.patch \
"

S = "${WORKDIR}/pybind11-${PV}"
OPENEULER_REPO_NAME = "pybind11"
OPENEULER_BRANCH = "openEuler-23.03"
SRC_URI_prepend += "file://v${PV}.tar.gz "


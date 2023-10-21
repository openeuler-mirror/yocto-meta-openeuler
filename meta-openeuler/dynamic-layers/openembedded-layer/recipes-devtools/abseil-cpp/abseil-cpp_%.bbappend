OPENEULER_SRC_URI_REMOVE = "https http git"

PV = "20230125.3"

SRC_URI = " \
        file://abseil-cpp-${PV}.tar.gz \
        "

EXTRA_OECMAKE += "-DABSL_ENABLE_INSTALL=ON"

S = "${WORKDIR}/abseil-cpp-${PV}"

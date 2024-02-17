
PV = "20230125.3"

SRC_URI = " \
        file://${BP}.tar.gz \
        "

EXTRA_OECMAKE += "-DABSL_ENABLE_INSTALL=ON"

S = "${WORKDIR}/${BP}"

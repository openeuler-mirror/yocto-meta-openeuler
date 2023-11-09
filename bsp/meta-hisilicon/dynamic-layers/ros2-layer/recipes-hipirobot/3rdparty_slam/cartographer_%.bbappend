DISABLE_OPENEULER_SOURCE_MAP = "1"

OPENEULER_LOCAL_NAME = "3rdparty_slam"

PR = "h1"

SRC_URI += " \
        file://${OPENEULER_LOCAL_NAME}/cartographer/ \
"

S = "${WORKDIR}/${OPENEULER_LOCAL_NAME}/cartographer"


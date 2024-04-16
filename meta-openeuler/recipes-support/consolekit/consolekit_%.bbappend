OPENEULER_LOCAL_NAME = "oee_archive"


SRC_URI:prepend = " \
    file://${OPENEULER_LOCAL_NAME}/${BPN}/ConsoleKit-${PV}.tar.xz \
"


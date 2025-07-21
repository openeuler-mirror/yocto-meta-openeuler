PV = "3.9.0"

OPENEULER_LOCAL_NAME = "python-prettytable"

SRC_URI:prepend = "file://prettytable-${PV}.tar.gz "
SRC_URI:remove = "file://run-ptest"

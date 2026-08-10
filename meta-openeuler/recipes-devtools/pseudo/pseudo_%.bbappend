# src verion is in yocto-pseudo repo
OPENEULER_LOCAL_NAME = "yocto-pseudo"

inherit oee-archive
OEE_ARCHIVE_SUB_DIR = "pseudo"

SRC_URI:prepend = "file://${BP}.tar.gz "

PV = "df1d1321fb093283485c387e3c933d2d264e509c"
S = "${WORKDIR}/${BP}"

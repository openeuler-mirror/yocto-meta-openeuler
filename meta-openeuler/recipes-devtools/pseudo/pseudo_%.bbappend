# src verion is in yocto-pseudo repo
# prebuilt version is in oee-archive repo
OPENEULER_LOCAL_NAME = "yocto-pseudo"

inherit oee-archive
OEE_ARCHIVE_SUB_DIR = "pseudo"

SRC_URI:prepend = "file://${BP}.tar.gz \
          file://pseudo-prebuilt-2.33.tar.xz;subdir=${BP}/prebuilt;name=prebuilt \
           "

PV = "df1d1321fb093283485c387e3c933d2d264e509c"
S = "${WORKDIR}/${BP}"

# older-glibc-symbols.patch is in scarthgap recipe but not needed for openeuler pseudo
SRC_URI:remove = "file://older-glibc-symbols.patch"

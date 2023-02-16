PV = "6.14"

SRC_URI_remove = "git://git.samba.org/cifs-utils.git;branch=master"

SRC_URI_prepend = "file://${BP}.tar.bz2 \
           "

SRC_URI[sha256sum] = "6609e8074b5421295ff012a31f02ccd9a058415c619c81362ebb788dbf0756b8"

S = "${WORKDIR}/${BP}"

# keep the same as before, otherwise a large number of dependencies will be introduced
DEPENDS_remove = "libtalloc"

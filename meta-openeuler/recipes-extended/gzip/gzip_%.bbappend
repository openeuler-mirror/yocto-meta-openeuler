# main bbfile: yocto-poky/meta/recipes-extended/gzip/gzip_1.10.bb

# gzip version in openEuler
PV = "1.11"

# Use the source packages from openEuler
SRC_URI_remove = "${GNU_MIRROR}/gzip/${BP}.tar.gz"
SRC_URI_prepend += "file://gzip/${BP}.tar.xz \
                    file://gzip/gzip-l-now-outputs-accurate-size.patch \
                    file://gzip/doc-document-gzip-l-change.patch \
                    file://gzip/zdiff-fix-arg-handling-bug.patch \
                    file://gzip/zdiff-fix-another-arg-handling-bug.patch \
                    file://gzip/fix-verbose-disable.patch \
                    "

# apply poky's patch
SRC_URI_remove_class-target = " file://wrong-path-fix.patch"
SRC_URI_append_class-target = " file://../gzip-1.10/wrong-path-fix.patch"

SRC_URI[md5sum] = "d1e93996dba00cab0caa7903cd01d454"
SRC_URI[sha256sum] = "9b9a95d68fdcb936849a4d6fada8bf8686cddf58b9b26c9c4289ed0c92a77907"

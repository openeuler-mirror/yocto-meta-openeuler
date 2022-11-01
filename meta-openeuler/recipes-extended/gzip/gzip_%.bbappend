# main bbfile: yocto-poky/meta/recipes-extended/gzip/gzip_1.10.bb

# gzip version in openEuler
PV = "1.11"

# Use the source packages from openEuler
SRC_URI_remove = "${GNU_MIRROR}/gzip/${BP}.tar.gz"
SRC_URI_prepend += "file://${BP}.tar.xz \
        file://gzip-l-now-outputs-accurate-size.patch \
        file://doc-document-gzip-l-change.patch \
        file://zdiff-fix-arg-handling-bug.patch \
        file://zdiff-fix-another-arg-handling-bug.patch \
        file://fix-verbose-disable.patch \
        file://backport-0001-CVE-2022-1271.patch \
        file://backport-0002-CVE-2022-1271.patch \
        file://backport-0003-CVE-2022-1271.patch \
        "
#this patch from openeuler can't apply: performance-neoncrc32-and-prfm.patch

# remove poky's conflicting patch
SRC_URI_remove_class-target = " file://wrong-path-fix.patch"

SRC_URI[md5sum] = "d1e93996dba00cab0caa7903cd01d454"
SRC_URI[sha256sum] = "9b9a95d68fdcb936849a4d6fada8bf8686cddf58b9b26c9c4289ed0c92a77907"

# main bbfile: yocto-poky/meta/recipes-extended/gzip/gzip_1.10.bb

OPENEULER_SRC_URI_REMOVE = "https git http"

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

# remove poky's conflicting patch
SRC_URI_remove_class-target = " file://wrong-path-fix.patch"

SRC_URI[md5sum] = "9608e4ac5f061b2a6479dc44e917a5db"
SRC_URI[sha256sum] = "ce5e03e519f637e1f814011ace35c4f87b33c0bbabeec35baf5fbd3479e91956"

OPENEULER_SRC_URI_REMOVE = "http git"

PV = "3.5"

LIC_FILES_CHKSUM = "file://${S}/LICENSE;md5=84b4d2c6ef954a2d4081e775a270d0d0"

SRC_URI:prepend = "file://${BP}.tar.gz \
           file://backport-libselinux-add-check-for-calloc-in-check_booleans.patch \
           file://do-malloc-trim-after-load-policy.patch \
           "

# patch in meta-selinux
SRC_URI += "file://0003-libselinux-restore-drop-the-obsolete-LSF-transitiona.patch"

S = "${WORKDIR}/${BP}"

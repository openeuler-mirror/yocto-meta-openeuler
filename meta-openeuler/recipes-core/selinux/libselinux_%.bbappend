
PV = "3.5"

LIC_FILES_CHKSUM = "file://${S}/LICENSE;md5=84b4d2c6ef954a2d4081e775a270d0d0"

SRC_URI:prepend = "file://${BP}.tar.gz \
           file://backport-libselinux-add-check-for-calloc-in-check_booleans.patch \
           file://backport-libselinux-utils-free-allocated-resources.patch \
           file://backport-libselinux-enable-usage-with-pedantic-UB-sanitizers.patch \
           file://backport-libselinux-reorder-calloc-3-arguments.patch \
           file://backport-libselinux-Fix-ordering-of-arguments-to-calloc.patch \
           file://backport-libselinux-use-reentrant-strtok_r-3.patch \
           file://do-malloc-trim-after-load-policy.patch \
           "

# patch in meta-selinux
SRC_URI += "file://0003-libselinux-restore-drop-the-obsolete-LSF-transitiona.patch"

S = "${WORKDIR}/${BP}"

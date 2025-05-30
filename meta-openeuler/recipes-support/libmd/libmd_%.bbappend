PV = "1.1.0"

SRC_URI:prepend = " \
    file://${BP}.tar.xz \
    file://backport-fix-out-of-tree-build.patch \
    file://backport-Refactor-autogen-call-into-before_script.patch \
    file://backport-fix-man-Sync-SHA2-changes-from-OpenBSD.patch \
"

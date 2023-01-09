FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"
# add patch to support musl
SRC_URI_append = " \
        file://libhugetlbfs-musl.patch \
"

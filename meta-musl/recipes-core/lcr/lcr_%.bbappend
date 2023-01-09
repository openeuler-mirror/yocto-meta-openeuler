FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"
# add patch to support musl
SRC_URI_append = " \
           file://lcr-for-musl.patch \
"

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"
# add patch to support musl
SRC_URI:append = " \
           file://libpam-for-musl.patch \
"

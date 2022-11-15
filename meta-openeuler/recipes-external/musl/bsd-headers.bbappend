# add patch to support musl
FILESEXTRAPATHS_prepend := "${THISDIR}/bsd-headers/:"
SRC_URI_append_libc-musl = " \
           file://sys-cdefs-musl.patch \
"

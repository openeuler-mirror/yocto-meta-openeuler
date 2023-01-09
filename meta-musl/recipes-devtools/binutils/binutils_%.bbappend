# add patch to support musl
FILESEXTRAPATHS_prepend := "${THISDIR}/binutils/:"
SRC_URI_append = " \
    file://use-static_cast.patch \
"

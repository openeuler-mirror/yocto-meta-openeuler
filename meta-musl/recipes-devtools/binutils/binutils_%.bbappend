# add patch to support musl
FILESEXTRAPATHS:prepend := "${THISDIR}/binutils/:"
SRC_URI:append = " \
    file://use-static_cast.patch \
"

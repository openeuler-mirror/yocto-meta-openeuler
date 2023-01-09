# add patch to support musl
FILESEXTRAPATHS_prepend := "${THISDIR}/iproute2:"
SRC_URI_append =" \
    file://missing-include.patch \
"

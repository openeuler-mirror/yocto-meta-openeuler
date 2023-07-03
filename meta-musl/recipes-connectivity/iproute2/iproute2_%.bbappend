# add patch to support musl
FILESEXTRAPATHS:prepend := "${THISDIR}/iproute2:"
SRC_URI:append =" \
    file://missing-include.patch \
"

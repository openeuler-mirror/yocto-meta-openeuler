FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
# add patch to support musl
SRC_URI:append = " \
        file://ethercat_musl.patch \
"

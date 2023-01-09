FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
# add patch to support musl
SRC_URI_append = " \
        file://ethercat_musl.patch \
"

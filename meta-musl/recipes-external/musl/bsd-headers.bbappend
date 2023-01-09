PACKAGES = "${PN}"

# add patch to support musl
FILESEXTRAPATHS_prepend := "${THISDIR}/bsd-headers/:"
SRC_URI_append = " \
           file://sys-cdefs-musl.patch \
"

FILES_${PN} = " \
    /usr/* \
"

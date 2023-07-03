PACKAGES = "${PN}"

# add patch to support musl
FILESEXTRAPATHS:prepend := "${THISDIR}/bsd-headers/:"
SRC_URI:append = " \
           file://sys-cdefs-musl.patch \
"

FILES:${PN} = " \
    /usr/* \
"

# add patch to support musl
FILESEXTRAPATHS_prepend := "${THISDIR}/rng-tools/:"
SRC_URI_append = " \
        file://rng-tools-musl.patch \
"

FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"
# add gcompat DEPENDS to support musl
DEPENDS_append = " gcompat "

SRC_URI_append = " \
        file://isulad-musl.patch \
"

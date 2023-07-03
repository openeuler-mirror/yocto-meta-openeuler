FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"
# add gcompat DEPENDS to support musl
DEPENDS:append = " gcompat "

SRC_URI:append = " \
        file://isulad-musl.patch \
"

# patch directary
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

# add patch to support musl
SRC_URI:append = " \
        file://libgpg-error-musl.patch \
"

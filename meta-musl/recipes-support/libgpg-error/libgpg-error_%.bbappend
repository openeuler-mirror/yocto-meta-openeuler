# patch directary
FILESEXTRAPATHS_append := "${THISDIR}/files/:"

# add patch to support musl
SRC_URI_append += " \
        file://libgpg-error-musl.patch \
"

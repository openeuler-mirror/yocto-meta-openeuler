FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"
# add patch to support musl
SRC_URI_append = " \
        file://change-musl-toolchain.patch;patchdir=${S}/build \
        file://dsoftbus-musl.patch;patchdir=${WORKDIR}/dsoftbus_standard \
"

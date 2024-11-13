#add musl libc toolchain prefix
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append = " \
        file://0001-feat-for-embedded-add-linux_arm64-musl-toolchain.patch;patchdir=${WORKDIR}/${pkg-build} \
"

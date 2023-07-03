FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"
# add patch to support musl
SRC_URI:append = " \
           file://change-musl-toolchain.patch;patchdir=${S}/build \
"
SRC_URI:append:toolchain-clang = " \
           file://musl-clang.patch;patchdir=${S}/build \
"
SRC_URI:remove:toolchain-clang = " \
           file://0001-change-toolchain-for-clang-build.patch;patchdir=${S}/build \
"

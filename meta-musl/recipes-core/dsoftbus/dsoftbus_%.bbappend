FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"
# add patch to support musl
SRC_URI_append = " \
           file://change-musl-toolchain.patch;patchdir=${S}/build \
"
SRC_URI_append_toolchain-clang = " \
           file://musl-clang.patch;patchdir=${S}/build \
"
SRC_URI_remove_toolchain-clang = " \
           file://0001-change-toolchain-for-clang-build.patch;patchdir=${S}/build \
"

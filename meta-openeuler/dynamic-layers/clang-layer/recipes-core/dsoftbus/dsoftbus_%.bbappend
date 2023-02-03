FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"
# add patch to support clang
SRC_URI_append = " \
        file://0001-change-toolchain-for-clang-build.patch;patchdir=${S}/build \
"

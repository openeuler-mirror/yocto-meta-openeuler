FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# fix segmentfault error when compiling with clang
SRC_URI:append = " \
        file://remove-asprintf-declaration-for-clang-build.patch \
"

CFLAGS:append = " -DHAVE_ASPRINTF "

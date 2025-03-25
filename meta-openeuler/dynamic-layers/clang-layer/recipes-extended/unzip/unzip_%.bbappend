FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# fix error when compiling with clang
SRC_URI:append:toolchain-clang = " \
        file://0001-adapt-configure-for-clang-compile.patch \
"

CFLAGS:append:toolchain-clang = " -Wno-error=implicit-int -Wno-error=implicit-function-declaration "
CXXFLAGS:append:toolchain-clang = " -Wno-error=implicit-int -Wno-error=implicit-function-declaration "

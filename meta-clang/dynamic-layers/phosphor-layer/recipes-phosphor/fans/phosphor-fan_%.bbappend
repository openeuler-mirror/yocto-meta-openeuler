FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

SRC_URI:append:toolchain-clang = " \
	file://0001-adapt-clang-build.patch \
"

CXXFLAGS:append:toolchain-clang = " -Wno-error=defaulted-function-deleted -Wno-error=unused-lambda-capture -Wno-error=unused-private-field "

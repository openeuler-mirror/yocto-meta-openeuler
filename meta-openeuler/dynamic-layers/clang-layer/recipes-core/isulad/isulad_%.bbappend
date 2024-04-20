FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# fix werror when compiling with clang
SRC_URI:append:toolchain-clang = " \
	file://0001-add-Wno-error-for-clang-compile.patch \
"

FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# fix werror when compiling with clang
SRC_URI:append:toolchain-clang = " \
	file://0001-add-Wno-error-for-clang-compile.patch \
"

OECMAKE_C_COMPILER:append:toolchain-clang = "${@bb.utils.contains('DISTRO_FEATURES', 'ld-is-lld', ' -fuse-ld=lld -Wno-error=unused-command-line-argument', '', d)}"

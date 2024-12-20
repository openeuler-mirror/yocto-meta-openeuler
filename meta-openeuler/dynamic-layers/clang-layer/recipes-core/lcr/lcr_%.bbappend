FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

# fix werror when compiling with clang

SRC_URI:append = " \
						file://0015-fix-invalid-args-len-set-in-execute_lxc_attach.patch \
						file://0016-add-nri-definitions.patch \
						file://0017-add-struct-for-nri.patch \
						file://0018-add-nri-def-in-host-config.patch \
						file://0019-fix-invalid-usage-of-arrtibute-visibility.patch \
						file://0020-unify-nri-variable-format.patch \
						file://0021-sandbox-sandbox-api-update.patch \
						file://0022-json-schema-for-sandbox-api.patch \
						file://0023-add-no-pivot-root-config.patch \
						file://0024-Use-any-type-instead-of-bytearray.patch \
						file://0025-fix-issues-Isula-ps-cannot-display-port-mapping.patch \
"

SRC_URI:append:toolchain-clang = " \
	file://0001-add-Wno-error-for-clang-compile.patch \
"
OECMAKE_C_COMPILER:append:toolchain-clang = "${@bb.utils.contains('DISTRO_FEATURES', 'ld-is-lld', ' -fuse-ld=lld -Wno-error=unused-command-line-argument', '', d)}"

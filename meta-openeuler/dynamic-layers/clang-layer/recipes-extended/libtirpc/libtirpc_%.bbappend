# fix error:
# ld.lld: error: version script assignment of 'TIRPC_0.3.0' to symbol '_svcauth_gss' failed: symbol not defined
LDFLAGS:append:toolchain-clang = "${@bb.utils.contains('DISTRO_FEATURES', 'ld-is-lld', ' -Wl,--undefined-version', '', d)}"

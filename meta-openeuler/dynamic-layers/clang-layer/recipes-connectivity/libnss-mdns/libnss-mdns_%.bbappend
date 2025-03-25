# fix error:
# ld.lld: error: version script assignment of 'NSSMDNS_0' to symbol '_nss_mdns_gethostbyaddr_r' failed: symbol not defined
LDFLAGS:append:toolchain-clang = "${@bb.utils.contains('DISTRO_FEATURES', 'ld-is-lld', ' -Wl,--undefined-version', '', d)}"

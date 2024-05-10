# fix error:
# ld.lld: error: version script assignment of 'libnl_3_6' to symbol 'rtnl_link_info_ops_get' failed: symbol not defined
LDFLAGS:append:toolchain-clang = "${@bb.utils.contains('DISTRO_FEATURES', 'ld-is-lld', ' -Wl,--undefined-version', '', d)}"

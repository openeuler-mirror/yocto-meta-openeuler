CC:append:toolchain-clang = "${@bb.utils.contains('DISTRO_FEATURES', 'ld-is-lld', ' -fuse-ld=lld', '', d)}"

# In zlib configure stage, it will check whether support shard library by a simple case.
# By LLVM and LLD it gets error like,
# ld.lld: error: version script assignment of 'ZLIB_1.2.0' to symbol 'compressBound' failed: symbol not defined
# It uses CC and CFLAGS to compile it, so pass this option to CFLAGS.
CFLAGS:append:toolchain-clang = "${@bb.utils.contains('DISTRO_FEATURES', 'ld-is-lld', ' -Wl,--undefined-version', '', d)}"

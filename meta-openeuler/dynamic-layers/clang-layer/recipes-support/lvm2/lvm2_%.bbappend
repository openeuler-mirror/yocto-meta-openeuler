CFLAGS:append:toolchain-clang = " -Wno-error=implicit-function-declaration "
LDFLAGS:append:toolchain-clang = "${@bb.utils.contains('DISTRO_FEATURES', 'ld-is-lld', ' -Wl,--undefined-version', '', d)}"


# append LDFLAGS dynamic-linker to ld-linux-aarch64.so.1 for musl
#
LDFLAGS:remove:toolchain-clang:class-nativesdk:aarch64 = " -Wl,-dynamic-linker,${base_libdir}/ld-linux-aarch64.so.1"
LDFLAGS:remove:toolchain-clang:class-target:aarch64 = " -Wl,-dynamic-linker,${base_libdir}/ld-linux-aarch64.so.1"
LDFLAGS:append:toolchain-clang:class-nativesdk:aarch64 = " -Wl,-dynamic-linker,${base_libdir}/ld-musl-aarch64.so.1"
LDFLAGS:append:toolchain-clang:class-target:aarch64 = " -Wl,-dynamic-linker,${base_libdir}/ld-musl-aarch64.so.1"

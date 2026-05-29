
# musl libc.so has no DT_SONAME in the external ARM toolchain binary, so
# package_do_shlibs() cannot auto-register it via objdump -p.
# Tell BitBake explicitly that libc.so is provided by the musl package so
# that file-rdeps QA checks pass for all packages that link libc.so
# (libffi, zlib, openssl, busybox, ...).
# Format: "libname:pkgname" — no version so any musl version satisfies it.
ASSUME_SHLIBS:append:arm = " libc.so:musl"

# append LDFLAGS dynamic-linker to ld-linux-aarch64.so.1 for musl
#
LDFLAGS:remove:toolchain-clang:class-nativesdk:aarch64 = " -Wl,-dynamic-linker,${base_libdir}/ld-linux-aarch64.so.1"
LDFLAGS:remove:toolchain-clang:class-target:aarch64 = " -Wl,-dynamic-linker,${base_libdir}/ld-linux-aarch64.so.1"
LDFLAGS:append:toolchain-clang:class-nativesdk:aarch64 = " -Wl,-dynamic-linker,${base_libdir}/ld-musl-aarch64.so.1"
LDFLAGS:append:toolchain-clang:class-target:aarch64 = " -Wl,-dynamic-linker,${base_libdir}/ld-musl-aarch64.so.1"

LDFLAGS:append:toolchain-clang:class-nativesdk:arm = " -Wl,-dynamic-linker,${base_libdir}/ld-musl-arm.so.1"
LDFLAGS:append:toolchain-clang:class-target:arm = " -Wl,-dynamic-linker,${base_libdir}/ld-musl-arm.so.1"

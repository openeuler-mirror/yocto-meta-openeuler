PREFERRED_PROVIDER_gmp-native = "gcc-bin-toolchain-cross-${TARGET_ARCH}"
PREFERRED_PROVIDER_libmpc-native = "gcc-bin-toolchain-cross-${TARGET_ARCH}"
PREFERRED_PROVIDER_mpfr-native = "gcc-bin-toolchain-cross-${TARGET_ARCH}"
PREFERRED_PROVIDER_virtual/${TARGET_PREFIX}binutils = "gcc-bin-toolchain-cross-${TARGET_ARCH}"
PREFERRED_PROVIDER_virtual/${TARGET_PREFIX}gcc = "gcc-bin-toolchain-cross-${TARGET_ARCH}"
PREFERRED_PROVIDER_virtual/${TARGET_PREFIX}g++ = "gcc-bin-toolchain-cross-${TARGET_ARCH}"
PREFERRED_PROVIDER_virtual/${TARGET_PREFIX}compilerlibs = "gcc-bin-toolchain-compilerlibs-${TARGET_ARCH}"
PREFERRED_PROVIDER_gcc-runtime = "gcc-bin-toolchain-compilerlibs-${TARGET_ARCH}"
PREFERRED_PROVIDER_virtual/libc = "glibc"
PREFERRED_PROVIDER_virtual/libc-headers = "linux-libc-headers"
PREFERRED_PROVIDER_libstdc++ = "gcc-bin-toolchain-compilerlibs-${TARGET_ARCH}"
PREFERRED_PROVIDER_libgcc-initial = "gcc-bin-toolchain-compilerlibs-${TARGET_ARCH}"

PATH_append = ":${COMPONENTS_DIR}/${BUILD_ARCH}/gcc-bin-toolchain-cross-${TARGET_ARCH}/bin"

#cannot set with linaro gcc,set it null
DEBUG_PREFIX_MAP = ""

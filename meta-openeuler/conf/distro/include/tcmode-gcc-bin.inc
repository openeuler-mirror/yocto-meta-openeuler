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

# PREFERRED_PROVIDER_libgcc-initial = "gcc-bin-toolchain-libgcc"
# PREFERRED_PROVIDER_libgcc = "gcc-bin-toolchain-libgcc"
# PREFERRED_PROVIDER_compiler-rt = "gcc-bin-toolchain-libgcc"
# PREFERRED_PROVIDER_libunwind-llvm = "gcc-bin-toolchain-libgcc"
# PREFERRED_PROVIDER_libcxx = "gcc-bin-toolchain-runtime"
# PREFERRED_PROVIDER_libcxxabi = "gcc-bin-toolchain-runtime"

GCCVERSION = "7.3.0"

PATH_append = ":${COMPONENTS_DIR}/${BUILD_ARCH}/gcc-bin-toolchain-cross-${TARGET_ARCH}/usr/bin"

#cannot set with linaro gcc,set it null
DEBUG_PREFIX_MAP = ""
#STAGING_DIR_TARGET:arm = "/usr1/openeuler/gcc/sysroot-glibc-linaro-2.25-2018.05-arm-linux-gnueabi"
#STAGING_DIR_TARGET:aarch64 = "/usr1/openeuler/gcc/sysroot-glibc-linaro-2.25-2018.05-aarch64-linux-gnu"

inherit external-toolchain-cross

EXTERNAL_TOOLCHAIN = "${EXTERNAL_TOOLCHAIN_LLVM}"

PV = "${CLANG_VERSION}"
PN .= "-${TARGET_ARCH}"
DEPENDS += "virtual/${TARGET_PREFIX}binutils"

EXTERNAL_CROSS_BINARIES = "clang clang++"

PROVIDES += "\
    clang-cross-${TARGET_ARCH} \
"

EXTERNAL_CROSS_BINARIES = "clang clang++ lld ld.lld llvm-profdata \
        llvm-nm llvm-ar llvm-as llvm-ranlib llvm-strip llvm-objcopy llvm-objdump \
        llvm-readelf llvm-addr2line llvm-dwp llvm-size llvm-strings llvm-cov llvm-cxxfilt \
"

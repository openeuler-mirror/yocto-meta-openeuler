inherit external-toolchain-cross

EXTERNAL_TOOLCHAIN = "${EXTERNAL_TOOLCHAIN_LLVM}"

PV = "${CLANG_VERSION}"
PN .= "-${TARGET_ARCH}"
DEPENDS += "virtual/${TARGET_PREFIX}binutils"

EXTERNAL_CROSS_BINARIES = "clang clang++"

PROVIDES += "\
    clang-cross-${TARGET_ARCH} \
"


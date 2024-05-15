require clang-external.inc
inherit external-toolchain-cross

PN .= "-${TARGET_ARCH}"

DEPENDS += "virtual/${TARGET_PREFIX}binutils"

PROVIDES += "\
    clang-cross-${TARGET_ARCH} \
"

EXTERNAL_CROSS_BINARIES = "${clang_binaries}"

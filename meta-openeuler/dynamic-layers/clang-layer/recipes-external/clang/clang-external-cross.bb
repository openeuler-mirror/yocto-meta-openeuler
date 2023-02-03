inherit external-toolchain-cross

PV = "${CLANG_VERSION}"
PN .= "-${TARGET_ARCH}"
DEPENDS += "virtual/${TARGET_PREFIX}binutils"

EXTERNAL_CROSS_BINARIES = "clang clang++"


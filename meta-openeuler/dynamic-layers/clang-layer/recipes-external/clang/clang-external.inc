LICENSE = "CLOSED"

EXTERNAL_TOOLCHAIN = "${EXTERNAL_TOOLCHAIN_LLVM}"

PV = "${CLANG_VERSION}"

clang_binaries = "clang clang++ lld ld.lld llvm-profdata \
        llvm-nm llvm-ar llvm-as llvm-ranlib llvm-strip llvm-objcopy llvm-objdump \
        llvm-readelf llvm-addr2line llvm-dwp llvm-size llvm-strings llvm-cov llvm-cxxfilt \
"

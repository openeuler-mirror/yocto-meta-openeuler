inherit common-license native
LICENSE = "CLOSED"

EXTERNAL_NATIVE_BINARIES = "clang clang++ ld.lld lld llvm-ar llvm-nm llvm-objcopy llvm-objdump llvm-ranlib llvm-strip \
                     llvm-addr2line llvm-cxxfilt llvm-readelf llvm-size llvm-strings"

PV = "${CLANG_VERSION}"
wrap_bin () {
    bin="$1"
    shift
    script="${D}${bindir}/${bin}"
    extraargs=""
    case $bin in
        clang*)
            # compiler is support prebuilt tool now
            extraargs="--target=x86_64-openeulersdk-linux"
            ;;
        *)
            ;;
    esac
    execcmd="exec ${EXTERNAL_TOOLCHAIN_CLANG_BIN}/$bin $extraargs \"\$@\""
    printf '#!/bin/sh\n' >$script
    for arg in "$@"; do
        printf '%s\n' "$arg"
    done >>"$script"
    printf '%s\n' "${execcmd}" >>"$script"
    chmod +x "$script"
}

do_install () {
    install -d ${D}${bindir}
    for bin in ${EXTERNAL_NATIVE_BINARIES}; do
        if [ ! -e "${EXTERNAL_TOOLCHAIN_CLANG_BIN}/${bin}" ]; then
            bbdebug 1 "${EXTERNAL_TOOLCHAIN_CLANG_BIN}/${bin} does not exist"
            continue
        fi
        bbdebug 1 wrap_bin "$bin"
        wrap_bin "${bin}"
    done
}

require clang-external.inc
inherit common-license native

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

EXTERNAL_CROSS_BINARIES = "${clang_binaries}"

do_install () {
    install -d ${D}${bindir}
    for bin in ${EXTERNAL_CROSS_BINARIES}; do
        if [ ! -e "${EXTERNAL_TOOLCHAIN_CLANG_BIN}/${bin}" ]; then
            bbdebug 1 "${EXTERNAL_TOOLCHAIN_CLANG_BIN}/${bin} does not exist"
            continue
        fi
        bbdebug 1 wrap_bin "$bin"
        wrap_bin "${bin}"
    done
}

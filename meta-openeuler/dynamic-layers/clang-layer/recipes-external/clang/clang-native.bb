inherit common-license native
LICENSE = "CLOSED"

PV = "${CLANG_VERSION}"
wrap_bin () {
    bin="$1"
    shift
    script="${D}${bindir}/${bin}"
    # compiler is support nativesdk now
    execcmd="exec ${EXTERNAL_TOOLCHAIN_CLANG_BIN}/${bin} --target=x86_64-openeulersdk-linux \"\$@\""
    printf '#!/bin/sh\n' >$script
    for arg in "$@"; do
        printf '%s\n' "$arg"
    done >>"$script"
    printf '%s\n' "${execcmd}" >>"$script"
    chmod +x "$script"
}

do_install () {
    install -d ${D}${bindir}
    for bin in clang clang++; do
        if [ ! -e "${EXTERNAL_TOOLCHAIN_CLANG_BIN}/${bin}" ]; then
            bbdebug 1 "${EXTERNAL_TOOLCHAIN_CLANG_BIN}/${bin} does not exist"
            continue
        fi
        bbdebug 1 wrap_bin "$bin"
        wrap_bin "${bin}"
    done
}

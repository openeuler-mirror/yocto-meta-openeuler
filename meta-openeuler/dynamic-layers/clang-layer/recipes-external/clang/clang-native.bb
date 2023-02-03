inherit common-license native
LICENSE = "CLOSED"

nativesdk_incdir = "${OPENEULER_NATIVESDK_SYSROOT}/usr/include"
nativesdk_libdir = "${OPENEULER_NATIVESDK_SYSROOT}/usr/lib"
nativesdk_libgccdir = "${OPENEULER_NATIVESDK_SYSROOT}/usr/lib/x86_64-pokysdk-linux/10.3.0"
nativesdk_ldso = "${OPENEULER_NATIVESDK_SYSROOT}/lib/ld-linux-x86-64.so.2"

PV = "${CLANG_VERSION}"
wrap_bin () {
    bin="$1"
    shift
    script="${D}${bindir}/${bin}"
    execcmd="exec ${EXTERNAL_TOOLCHAIN_CLANG_BIN}/${bin} -isystem ${nativesdk_incdir} -B ${nativesdk_libdir} -B ${nativesdk_libgccdir} -L ${nativesdk_libgccdir} -Wl,--dynamic-linker,${nativesdk_ldso}  \"\$@\""
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

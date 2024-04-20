inherit external-toolchain cross

EXTERNAL_CROSS_BINARIES ?= ""

# Modify wrap_bin for clang/llvm wrapper
# When using clang/clang++ for cross compiler, it needs gcc-toolchain, so add some parameter in needded.
# And remove prefix llvm- for binutils, because there are using hard code like ${HOST_PREFIX}objdump in package.bbclass
# and some package using hard code like ${TARGET_PREFIX}ar/as/... when do_configure task.
wrap_bin () {
    bin="$1"
    shift
    script="${D}${bindir}/${TARGET_PREFIX}$bin"
    execcmd="exec ${EXTERNAL_TOOLCHAIN_BIN}/${EXTERNAL_TARGET_SYS}-$bin \"\$@\""
    # for llvm compiler
    case $bin in
        clang*)
            execcmd="exec ${EXTERNAL_TOOLCHAIN_BIN}/$bin --target=${EXTERNAL_TARGET_SYS} -Wno-int-conversion \"\$@\""
            ;;
        llvm-*)
            execcmd="exec ${EXTERNAL_TOOLCHAIN_BIN}/$bin \"\$@\""
            ;;
        *lld)
            execcmd="exec ${EXTERNAL_TOOLCHAIN_BIN}/$bin \"\$@\""
            ;;
        *)
            ;;
    esac
    printf '#!/bin/sh\n' >$script
    for arg in "$@"; do
        printf '%s\n' "$arg"
    done >>"$script"
    printf '%s\n' "${execcmd}" >>"$script"
    chmod +x "$script"
}

do_install () {
    install -d ${D}${bindir}
    for bin in ${EXTERNAL_CROSS_BINARIES}; do
        if [ ! -e "${EXTERNAL_TOOLCHAIN_BIN}/${EXTERNAL_TARGET_SYS}-$bin" ] && [ ! -e "${EXTERNAL_TOOLCHAIN_BIN}/$bin" ]; then
            bbdebug 1 "${EXTERNAL_TOOLCHAIN_BIN}/${EXTERNAL_TARGET_SYS}-$bin or ${EXTERNAL_TOOLCHAIN_BIN}/$bin does not exist"
            continue
        fi

        bbdebug 1 wrap_bin "$bin"
        wrap_bin "$bin"
    done
}

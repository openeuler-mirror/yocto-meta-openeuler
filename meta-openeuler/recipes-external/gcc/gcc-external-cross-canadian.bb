require recipes-external/gcc/gcc-external.inc
inherit external-toolchain-cross-canadian

PN .= "-${TRANSLATED_TARGET_ARCH}"

BINV = "${GCC_VERSION}"

RDEPENDS:${PN} = "binutils-external-cross-canadian-${TRANSLATED_TARGET_ARCH}"
FILES:${PN} = "\
    ${libdir}/gcc/${EXTERNAL_TARGET_SYS}/${BINV} \
    ${libexecdir}/gcc/${EXTERNAL_TARGET_SYS}/${BINV} \
    ${libdir}/libcc1* \
    /lib64/libcc1* \
    ${@' '.join('${base_bindir}/${EXTERNAL_TARGET_SYS}-' + i for i in '${gcc_binaries}'.split())} \
"

# no debug package
FILES:${PN}-dbg = ""
# no need do autolibname(handle the dependency of .so libs)
# auto_libname in debian.bbclass will call ${TARGET_PREFIX}objdump to get shlibs2 related info
# for gcc-external-cross-canadian, can't find ${TARGET_PREFIX}objdump
AUTO_LIBNAME_PKGS = ""

external_libroot = "${@os.path.realpath('${EXTERNAL_TOOLCHAIN_LIBROOT}').replace(os.path.realpath('${EXTERNAL_TOOLCHAIN}') + '/', '/')}"
FILES_MIRRORS =. "${libdir}/gcc/${EXTERNAL_TARGET_SYS}/${BINV}/|${external_libroot}/\n"

INSANE_SKIP:${PN} += "dev-so staticdev"
INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_SYSROOT_STRIP = "1"

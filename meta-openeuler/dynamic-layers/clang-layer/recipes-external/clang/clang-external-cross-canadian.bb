inherit external-toolchain-cross-canadian

PN .= "-${TRANSLATED_TARGET_ARCH}"

PV = "${CLANG_VERSION}"

clanglibdir = "${exec_prefix}/lib"
clangincdir = "${exec_prefix}/include"

RDEPENDS:${PN} = "binutils-external-cross-canadian-${TRANSLATED_TARGET_ARCH}"
FILES:${PN} = "\
    ${bindir}/clang* \
    ${clanglibdir}/* \
    ${clangincdir}/* \
"

# no debug package
FILES:${PN}-dbg = ""
# no need do autolibname(handle the dependency of .so libs)
# auto_libname in debian.bbclass will call ${TARGET_PREFIX}objdump to get shlibs2 related info
# for gcc-external-cross-canadian, can't find ${TARGET_PREFIX}objdump
AUTO_LIBNAME_PKGS = ""


INSANE_SKIP:${PN} += "dev-so staticdev"
INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_SYSROOT_STRIP = "1"

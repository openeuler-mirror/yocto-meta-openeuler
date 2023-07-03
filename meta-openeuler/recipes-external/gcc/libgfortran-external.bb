SUMMARY = "The GNU Compiler Collection - libgfortran"
HOMEPAGE = "http://www.gnu.org/software/gcc/"
SECTION = "devel"
DEPENDS += "virtual/${TARGET_PREFIX}binutils"
PROVIDES += "libgfortran"
PV = "${GCC_VERSION}"

inherit external-toolchain

LICENSE = "GPL-3.0-with-GCC-exception"

BINV = "${GCC_VERSION}"
LIBROOT_RELATIVE = "${@os.path.relpath('${EXTERNAL_TOOLCHAIN_LIBROOT}', '${EXTERNAL_TOOLCHAIN}')}"

FILES:${PN} = "${base_libdir}/libgfortran.so.*"
FILES:${PN}-dev = "\
    ${base_libdir}/libgfortran*.so \
    ${base_libdir}/libgfortran.spec \
    ${base_libdir}/libgfortran.la \
    ${LIBROOT_RELATIVE}/libgfortranbegin.* \
    ${LIBROOT_RELATIVE}/libcaf_single* \
    ${LIBROOT_RELATIVE}/finclude/ \
    ${LIBROOT_RELATIVE}/include/ \
"
INSANE_SKIP:${PN}-dev += "staticdev"
FILES:${PN}-staticdev = "${libdir}/libgfortran.a"

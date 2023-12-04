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

# avoiding libc.so.6(GLIBC_2.38)(64bit), libgcc_s.so.1(GCC_3.0)(64bit), etc. no providers found
libc_rdep = "${@'${PREFERRED_PROVIDER_virtual/libc}' if '${PREFERRED_PROVIDER_virtual/libc}' else '${TCLIBC}'}"
RDEPENDS:${PN} += "${libc_rdep} libgcc-external"

FILES:${PN}-staticdev = "${libdir}/libgfortran.a"

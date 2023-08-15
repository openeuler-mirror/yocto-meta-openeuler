SUMMARY = "Library containing NIS functions using TI-RPC (IPv6 enabled)"
DESCRIPTION = "This library contains the public client interface for NIS(YP) and NIS+ \
               it was part of glibc and now is standalone packages. it also supports IPv6. \
               This recipe should work for extracting either the glibc or standalone libnsl \
               from the external toolchain."
HOMEPAGE = "https://github.com/thkukuk/libnsl"
LICENSE = "LGPL-2.1-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=4fbd65380cdd255951079008b364516c"
SECTION = "libs"

inherit external-toolchain

# although external toolchain may provide libnsl2, it just includes .so only,
# no dev related files, e.g., .a, .h. So better to use the libnsl2_git.bb which
# provides more details. To avoid the note warning msg "multi providers of libnsl2"
# change PN = libnsl2-openeuler-external. If possible, use the libnsl2 in the prebuilt
# toolchain after necessary optimization.
PN = "libnsl2-openeuler-external"

FILES:${PN} = "${libdir}/libnsl*.so.* ${libdir}/libnsl-*.so"
FILES:${PN}-dev = "${libdir}/libnsl.so ${includedir}/rpcsvc/nis*.h ${includedir}/rpcsvc/yp*.h"
FILES:${PN}-staticdev = "${libdir}/libnsl.a"

libc_rdep = "${@'${PREFERRED_PROVIDER_virtual/libc}' if d.getVar('PREFERRED_PROVIDER_virtual/libc') else '${TCLIBC}'}"
RDEPENDS:${PN} += "${libc_rdep}"

do_install_extra () {
    # Depending on whether this comes from the standalone libnsl2 or glibc, the
    # so name may vary, hence covering both 1 and 2, and it may be installed in
    # base_libdir instead of libdir, but the FILES configuration may result in its
    # location changing, breaking the libnsl.so symlink, so recreate it here.
    cd ${D}${libdir}/ || exit 1
    rm -f libnsl.so
    ln -s libnsl.so.[12] libnsl.so
}

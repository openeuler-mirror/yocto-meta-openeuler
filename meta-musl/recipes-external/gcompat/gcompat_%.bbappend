
do_install:append:riscv64 () {
   install -d ${D}${libdir}
   install -m 0755 ${S}/libgcompat.so.0 ${D}${libdir}/
   install -m 0755 ${S}/libgcompat.a ${D}${libdir}/

}

# The gcompat Makefile hardcodes /lib64 as the install prefix.
# On ARM the correct paths are ${base_libdir} and ${libdir}; move the
# files and clean up the mis-placed /lib64 / /usr/lib64 directories.
do_install:append:arm () {
    if [ -f "${D}/lib64/libgcompat.so.0" ]; then
        install -d ${D}${base_libdir}
        mv ${D}/lib64/libgcompat.so.0 ${D}${base_libdir}/
        rm -rf ${D}/lib64
    fi
    if [ -f "${D}/usr/lib64/libgcompat.a" ]; then
        install -d ${D}${libdir}
        mv ${D}/usr/lib64/libgcompat.a ${D}${libdir}/
        rm -rf ${D}/usr/lib64
    fi
}

INSANE_SKIP_{$PN}:append:riscv64 = "installed-vs-shipped"

FILES:${PN}:append:riscv64 = " /lib64"
FILES:${PN}-dev:append:riscv64 = " /lib64/libgcompat.so.0"
FILES:${PN}:append:riscv64 = " /usr/lib64"
FILES:${PN}-staticdev:append:riscv64 = " /usr/lib64/libgcompat.a"

FILES:${PN}:append:arm = " ${base_libdir}/libgcompat.so.0"
FILES:${PN}-staticdev:append:arm = " ${libdir}/libgcompat.a"

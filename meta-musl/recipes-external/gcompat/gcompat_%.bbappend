
do_install:append:riscv64 () {
   install -d ${D}${libdir}
   install -m 0755 ${S}/libgcompat.so.0 ${D}${libdir}/
   install -m 0755 ${S}/libgcompat.a ${D}${libdir}/

}

INSANE_SKIP_{$PN}:append:riscv64 = "installed-vs-shipped"

FILES:${PN}:append:riscv64 = " /lib64"
FILES:${PN}-dev:append:riscv64 = " /lib64/libgcompat.so.0"
FILES:${PN}:append:riscv64 = " /usr/lib64"
FILES:${PN}-staticdev:append:riscv64 = " /usr/lib64/libgcompat.a"


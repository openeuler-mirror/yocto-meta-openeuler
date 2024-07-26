musl_external_do_install_extra:riscv64 (){
    # Modify musl dynamic library search path
    mkdir -p ${D}${sysconfdir}
    touch ${D}${sysconfdir}/ld-musl-riscv64.path
    echo "${base_libdir}" > ${D}${sysconfdir}/ld-musl-riscv64.path
    echo "${libdir}" >> ${D}${sysconfdir}/ld-musl-riscv64.path

    # Support perf compile
    # Due to musl missing __always_inline definition
    sed -i '/#include <asm\/swab.h>/a\#include <sys/cdefs.h>' ${D}${includedir}/linux/swab.h
    sed -i '/#include <linux\/swab.h>/a\#include <sys/cdefs.h>' ${D}${includedir}/linux/byteorder/little_endian.h

    # Delete conflict file
    rm -f ${D}${base_libdir}/libgcc_s.so
    rm -f ${D}${base_libdir}/libgcc_s.so.1
}

# In case of conflict
FILES:${PN}:append:riscv64 = " \
    ${base_libdir}/../lib64/lp64d/ld-musl-riscv64.so.1 \
    ${sysconfdir}/ld-musl-riscv64.path \
"


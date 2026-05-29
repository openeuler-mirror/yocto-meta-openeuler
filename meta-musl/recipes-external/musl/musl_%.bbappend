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

musl_external_do_install_extra:arm (){
    mkdir -p ${D}${sysconfdir}
    touch ${D}${sysconfdir}/ld-musl-arm.path
    echo "${base_libdir}" > ${D}${sysconfdir}/ld-musl-arm.path
    echo "${libdir}" >> ${D}${sysconfdir}/ld-musl-arm.path

    if ${@bb.utils.contains('DISTRO_FEATURES', 'mini-img', 'false', 'true', d)}; then
        sed -i '/#include <asm\/swab.h>/a\#include <sys/cdefs.h>' ${D}${includedir}/linux/swab.h
        sed -i '/#include <linux\/swab.h>/a\#include <sys/cdefs.h>' ${D}${includedir}/linux/byteorder/little_endian.h
    fi

    rm -f ${D}${base_libdir}/libgcc_s.so
    rm -f ${D}${base_libdir}/libgcc_s.so.1

    # GCC companion libraries in /lib/ duplicate what gcc-runtime-external
    # installs in /usr/lib/.  Having two packages provide the same soname
    # causes "Multiple shlib providers" QA errors in every C++ package.
    # Remove them here; gcc-runtime-external owns the canonical copies.
    rm -f ${D}${base_libdir}/libstdc++.so*
    rm -f ${D}${base_libdir}/libatomic.so*
    rm -f ${D}${base_libdir}/libitm.so*
    rm -f ${D}${base_libdir}/libgfortran.so*
}

# The external ARM musl toolchain does not ship sys/cdefs.h (a BSD extension).
# musl_1.2.3.bb patches linux/swab.h to #include <sys/cdefs.h>, so bsd-headers
# must be in every recipe sysroot that transitively depends on musl.
# There is no file conflict because the musl toolchain sysroot does not provide
# sys/cdefs.h, sys/queue.h, or sys/tree.h.
DEPENDS:append:arm = " bsd-headers"

# musl_1.2.3.bb sets EXCLUDE_FROM_SHLIBS = "1", which prevents libc.so from
# being registered in the shlibs database. Without it, the file-rdeps QA check
# fails on every package that links libc.so (zlib, openssl, etc.) because the
# shlib auto-RDEPENDS mechanism cannot find a provider. Re-enable shlib tracking
# so that musl is automatically added to RDEPENDS of packages that need libc.so.
# NOTE: package_do_shlibs() checks `if d.getVar('EXCLUDE_FROM_SHLIBS'):` which
# is True for ANY non-empty string — "0" included — so we must use "".
EXCLUDE_FROM_SHLIBS = ""

RPROVIDES:${PN} += "glibc"
RPROVIDES:${PN}-dev += "glibc-dev"
RPROVIDES:${PN}-staticdev += "glibc-staticdev"

# RPM auto-generates rtld(GNU_HASH) as a REQUIRES for any binary compiled with
# GNU hash-style symbols (.gnu.hash ELF section). The PROVIDE must come from
# the package that contains the ELF interpreter. For musl on ARM the interpreter
# is /lib/ld-musl-arm.so.1, which lives in the musl package. rpmdeps does not
# auto-detect musl as the rtld provider, so declare it explicitly.
RPROVIDES:${PN}:append:arm = " rtld(GNU_HASH)"

FILES:${PN}:append:arm = " \
    ${base_libdir}/ld-musl-arm.so.1 \
    ${sysconfdir}/ld-musl-arm.path \
"

inherit cross
inherit eulertoolchain

require gcc-bin-toolchain.inc

INHIBIT_DEFAULT_DEPS = "1"

PROVIDES = "\
    virtual/${EULER_TOOLCHAIN_TARGET_PREFIX}binutils \
    virtual/${EULER_TOOLCHAIN_TARGET_PREFIX}gcc \
    virtual/${EULER_TOOLCHAIN_TARGET_PREFIX}g++ \
"

# Inherit cross but keep bindir/libdir/...:
bindir = "${exec_prefix}/bin/"
libdir = "${exec_prefix}/lib/"
libexecdir = "${exec_prefix}/libexec/"

do_install:class-cross() {
    install -m 0755 -d ${D}/${prefix}
    cp -pPR ${B}/* ${D}/${prefix}
    for f in ${D}/${prefix}/bin/${EULER_TOOLCHAIN_SYSNAME}-*; do
        bin=$(basename ${f})
        lnk=$(basename ${f} | sed "s/^${EULER_TOOLCHAIN_SYSNAME}-/${EULER_TOOLCHAIN_TARGET_PREFIX}/g")
        ln -svf ${bin} ${D}/${prefix}/bin/${lnk}
    done
    ln -svf ${EULER_TOOLCHAIN_SYSNAME} ${D}${libdir}/gcc/${EULER_TOOLCHAIN_TARGET_PREFIX_RAW}
}

SYSROOT_DIRS += "${prefix}/${EULER_TOOLCHAIN_SYSNAME} ${exec_prefix} /usr"

do_gcc_stash_builddir () {
    :
}
addtask do_gcc_stash_builddir

#depends by libgcc
do_packagedata () {
    :
}
addtask do_packagedata

INSANE_SKIP += "already-stripped"

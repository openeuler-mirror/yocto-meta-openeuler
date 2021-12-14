inherit cross
require gcc-bin-toolchain.inc

PN = "gcc-bin-toolchain-cross-${TARGET_ARCH}"
INHIBIT_DEFAULT_DEPS = "1"
INHIBIT_SYSROOT_STRIP = "1"

# Ignore how TARGET_ARCH is computed
TARGET_ARCH[vardepvalue] = "${TARGET_ARCH}"

PROVIDES = "\
    virtual/${TARGET_PREFIX}binutils \
    virtual/${TARGET_PREFIX}gcc \
    virtual/${TARGET_PREFIX}g++ \
"

# Inherit cross but keep bindir/libdir/...:
bindir = "${STAGING_DIR_NATIVE}/${prefix_native}/bin/"
libdir = "${STAGING_DIR_NATIVE}/${prefix_native}/${base_libdir}/"
libexecdir = "${STAGING_DIR_NATIVE}/${prefix_native}/libexec/"

do_install_class-cross() {
    install -m 0755 -d ${D}/${STAGING_DIR_NATIVE}
    cp -pPR ${B}/* ${D}/${STAGING_DIR_NATIVE}
    if [ ${TOOLCHAIN_PREFIX}- == ${TARGET_PREFIX} ]; then
	return
    fi
    for f in ${D}/${STAGING_DIR_NATIVE}/bin/${TOOLCHAIN_PREFIX}-*; do
        bin=$(basename ${f})
        lnk=$(basename ${f} | sed "s/^${TOOLCHAIN_PREFIX}-/${TARGET_PREFIX}/g")
        ln -svf ${bin} ${D}/${STAGING_DIR_NATIVE}/bin/${lnk}
    done
}

SYSROOT_DIRS += "/*"

do_gcc_stash_builddir () {
    :
}
addtask do_gcc_stash_builddir

#depends by libgcc
do_packagedata () {
    :
}
addtask do_packagedata

INSANE_SKIP_${PN} += " already-stripped "

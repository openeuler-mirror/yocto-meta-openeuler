inherit cross-canadian
require gcc-bin-toolchain.inc

# not depends to chrpath-native, use chrpath command at host
DEPENDS_remove += " chrpath-replacement-native"

PN = "gcc-bin-toolchain-cross-canadian-${TARGET_ARCH}"
INHIBIT_DEFAULT_DEPS = "1"
INHIBIT_PACKAGE_STRIP = "1"

# Ignore how TARGET_ARCH is computed
TARGET_ARCH[vardepvalue] = "${TARGET_ARCH}"

REAL_MULTIMACH_TARGET_SYS = "${TUNE_PKGARCH}${TARGET_VENDOR}-${TARGET_OS}"
SDKTARGETSYSROOT = "${SDKPATH}/sysroots/${REAL_MULTIMACH_TARGET_SYS}"

do_install() {
    install -m 0755 -d ${D}/${SDKTARGETSYSROOT}/
    #some files are under sysroot in compiler, need to copy to new sysroot
    cp -pPR ${B}/sysroot/* ${D}/${SDKTARGETSYSROOT}/
    cp -pPR ${B}/* ${D}/${SDKTARGETSYSROOT}/
    if [ ${TOOLCHAIN_PREFIX}- == ${TARGET_PREFIX} ]; then
        return 0
    fi
    for f in ${D}/${SDKTARGETSYSROOT}/bin/${TOOLCHAIN_PREFIX}-*; do
        bin=$(basename ${f})
        lnk=$(basename ${f} | sed "s/^${TOOLCHAIN_PREFIX}-/${TARGET_PREFIX}/g")
        ln -svf ${bin} ${D}/${SDKTARGETSYSROOT}/bin/${lnk}
    done
    chown -R root:root ${D}
}

SYSROOT_DIRS = ""

INSANE_SKIP_${PN} += " already-stripped libdir staticdev dev-so infodir"
FILES_${PN} = "/"
PACKAGES = "${PN}"

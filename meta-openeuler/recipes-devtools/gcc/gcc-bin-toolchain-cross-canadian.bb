inherit cross-canadian
require gcc-bin-toolchain.inc

# not depends to chrpath-native, use chrpath command at host
DEPENDS_remove += " chrpath-replacement-native"

PN = "gcc-bin-toolchain-cross-canadian-${TARGET_ARCH}"
INHIBIT_DEFAULT_DEPS = "1"
INHIBIT_PACKAGE_STRIP = "1"

# Ignore how TARGET_ARCH is computed
TARGET_ARCH[vardepvalue] = "${TARGET_ARCH}"

SDKINSTALLDIR = "${SDKPATHNATIVE}"

do_install() {
    install -m 0755 -d ${D}/${SDKINSTALLDIR}/
    #some files are under sysroot in compiler, need to copy to new sysroot
    cp -pPR ${B}/sysroot/* ${D}/${SDKINSTALLDIR}/
    cp -pPR ${B}/* ${D}/${SDKINSTALLDIR}/
    if [ ${TOOLCHAIN_PREFIX}- == ${TARGET_PREFIX} ]; then
        chown -R root:root ${D}
        return 0
    fi
    for f in ${D}/${SDKINSTALLDIR}/bin/${TOOLCHAIN_PREFIX}-*; do
        bin=$(basename ${f})
        lnk=$(basename ${f} | sed "s/^${TOOLCHAIN_PREFIX}-/${TARGET_PREFIX}/g")
        ln -svf ${bin} ${D}/${SDKINSTALLDIR}/bin/${lnk}
    done
    chown -R root:root ${D}
}

SYSROOT_DIRS = ""

INSANE_SKIP_${PN} += " already-stripped libdir staticdev dev-so infodir"
FILES_${PN} = "/"
PACKAGES = "${PN}"

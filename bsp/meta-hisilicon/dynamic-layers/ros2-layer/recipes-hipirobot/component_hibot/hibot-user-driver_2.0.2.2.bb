SUMMARY = "hirobot user driver bin package"
DESCRIPTION = "user lib and headers repack from SS928V100_SDK"
HOMEPAGE = "hipirobot/3rdparty_ss928v100_v2.0.2.2.git"
LICENSE = "CLOSED"

inherit pkgconfig
inherit ros_distro_humble

OPENEULER_LOCAL_NAME = "3rdparty_ss928v100_v2.0.2.2"

SRC_URI = " \
        file://3rdparty_ss928v100_v2.0.2.2/org/smp/a55_linux/mpp/out/lib \
        file://3rdparty_ss928v100_v2.0.2.2/org/smp/a55_linux/mpp/out/include \
        file://hibot-user-driver.pc.in \
"

S = "${WORKDIR}/3rdparty_ss928v100_v2.0.2.2/org/smp/a55_linux/mpp/out"

do_install:append() {
    install -d ${D}${libdir}
    install -d ${D}/usr/include
    cp -rf -P ${S}/lib/* ${D}${libdir}
    cp -rf -P ${S}/include/* ${D}/usr/include/
    cd ${D}${libdir}
    ln -s libsecurec.so libboundscheck.so
    cd -
    sed \
    -e s#@VERSION@#${PV}# \
    -e s#@prefix@#${prefix}# \
    -e s#@exec_prefix@#${exec_prefix}# \
    -e s#@libdir@#${libdir}# \
    -e s#@includedir@#${includedir}# \
    ${WORKDIR}/hibot-user-driver.pc.in > ${WORKDIR}/hibot-user-driver.pc

    install -d ${D}${libdir}/pkgconfig
    install -m 0644 ${WORKDIR}/hibot-user-driver.pc ${D}${libdir}/pkgconfig/

}

FILES:${PN} += " \
    ${libdir}/*so* \
    ${libdir}/npu/*so* \
    ${libdir}/svp_npu/*so* \
    ${libdir}/npu/stub/*so* \
"

FILES:${PN}-dev = " \
    ${includedir} \
    ${libdir}/pkgconfig \
"

FILES:${PN}-staticdev += " \
    ${libdir}/npu/*a \
    ${libdir}/svp_npu/*a \
"
 
EXCLUDE_FROM_SHLIBS = "1"
INSANE_SKIP:${PN} += "already-stripped dev-so"

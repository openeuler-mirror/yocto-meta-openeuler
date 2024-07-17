SUMMARY = "lib depneds from hieuler_component_ai app"
DESCRIPTION = "user lib for ai demo"
HOMEPAGE = "hipirobot/hieuler_component_ai"
LICENSE = "CLOSED"

inherit ros_distro_humble

OPENEULER_LOCAL_NAME = "hieuler_component_ai"

SRC_URI = " \
        file://hieuler_component_ai/component \
"

S = "${WORKDIR}/hieuler_component_ai/component"

do_install:append() {
    install -d ${D}${libdir}
    install -d ${D}/res
    cp -rf -P ${WORKDIR}/hieuler_component_ai/component/gesture_detection/lib/*so ${D}${libdir}
    cp -rf -P ${WORKDIR}/hieuler_component_ai/component/body_detection/lib/*so ${D}${libdir}
    cp -rf -P ${WORKDIR}/hieuler_component_ai/component/barcode_detection/res/* ${D}/res
    cp -rf -P ${WORKDIR}/hieuler_component_ai/component/gesture_detection/res/* ${D}/res
    cp -rf -P ${WORKDIR}/hieuler_component_ai/component/body_detection/res/* ${D}/res

}

# runtime dependencies, the following packages are required by the driver library
RDEPENDS:${PN} += " \
    hieulerpi1-user-driver \
"

FILES:${PN} += " \
    ${libdir}/*so* \
    /res/* \
"

FILES:${PN}-dev = ""

INSANE_SKIP:${PN} += "already-stripped dev-so"

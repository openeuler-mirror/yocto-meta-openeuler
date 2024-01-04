SUMMARY = "lib depneds from hirobot_component_ai app"
DESCRIPTION = "user lib for ai demo"
HOMEPAGE = "hipirobot/hirobot_component_ai"
LICENSE = "CLOSED"

inherit ros_distro_humble

OPENEULER_LOCAL_NAME = "hirobot_component_ai"

SRC_URI = " \
        file://hirobot_component_ai/component \
"

S = "${WORKDIR}/hirobot_component_ai/component"

do_install:append() {
    install -d ${D}${libdir}
    install -d ${D}/res
    cp -rf -P ${WORKDIR}/hirobot_component_ai/component/gesture_detection/lib/*so ${D}${libdir}
    cp -rf -P ${WORKDIR}/hirobot_component_ai/component/body_detection/lib/*so ${D}${libdir}
    cp -rf -P ${WORKDIR}/hirobot_component_ai/component/barcode_detection/res/* ${D}/res
    cp -rf -P ${WORKDIR}/hirobot_component_ai/component/gesture_detection/res/* ${D}/res
    cp -rf -P ${WORKDIR}/hirobot_component_ai/component/body_detection/res/* ${D}/res

}

FILES:${PN} += " \
    ${libdir}/*so* \
    /res/* \
"

FILES:${PN}-dev = ""

EXCLUDE_FROM_SHLIBS = "1"
INSANE_SKIP:${PN} += "already-stripped dev-so"

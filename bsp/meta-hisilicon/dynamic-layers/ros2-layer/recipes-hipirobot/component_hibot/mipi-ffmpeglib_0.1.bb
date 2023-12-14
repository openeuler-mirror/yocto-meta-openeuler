SUMMARY = "lib depneds from mipi app"
DESCRIPTION = "user lib for mipi"
HOMEPAGE = "hipirobot/component_ai"
LICENSE = "CLOSED"

inherit ros_distro_humble

OPENEULER_LOCAL_NAME = "component_ai"

SRC_URI = " \
        file://component_ai/sample/camera/src/ffmpeglib/lib \
"

S = "${WORKDIR}/component_ai/sample/camera/src/ffmpeglib/lib"

do_install:append() {
    install -d ${D}${libdir}
    cp -rf -P ${WORKDIR}/component_ai/sample/camera/src/ffmpeglib/lib/* ${D}${libdir}
}

FILES:${PN} += " \
    ${libdir}/*so* \
"

FILES:${PN}-dev = ""

EXCLUDE_FROM_SHLIBS = "1"
INSANE_SKIP:${PN} += "already-stripped dev-so"

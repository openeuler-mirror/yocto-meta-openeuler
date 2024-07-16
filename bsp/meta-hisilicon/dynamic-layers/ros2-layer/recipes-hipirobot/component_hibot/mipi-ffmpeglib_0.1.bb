SUMMARY = "user lib for mipi"
DESCRIPTION = "user lib for mipi"
HOMEPAGE = "hipirobot/hieuler_component_ai"
LICENSE = "CLOSED"

inherit ros_distro_humble

OPENEULER_LOCAL_NAME = "hieuler_component_ai"

SRC_URI = " \
        file://hieuler_component_ai/sample/camera/src/ffmpeglib/lib \
"

S = "${WORKDIR}/hieuler_component_ai/sample/camera/src/ffmpeglib/lib"

do_install:append() {
    install -d ${D}${libdir}
    cp -rf -P ${WORKDIR}/hieuler_component_ai/sample/camera/src/ffmpeglib/lib/* ${D}${libdir}
}

# runtime dependencies, the following packages are required by the driver library
RDEPENDS:${PN} += " \
    glibc-external \
    libstdc++ \
    libgcc-external \
"

FILES:${PN} += " \
    ${libdir}/*so* \
"

FILES:${PN}-dev = ""

EXCLUDE_FROM_SHLIBS = "1"
INSANE_SKIP:${PN} += "already-stripped dev-so"

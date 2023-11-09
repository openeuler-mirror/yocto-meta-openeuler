SUMMARY = "libhibot"
DESCRIPTION = "hibot from component_hibot"
HOMEPAGE = "hipirobot/component_hibot.git"
LICENSE = "CLOSED"

OPENEULER_LOCAL_NAME = "component_hibot"
SRC_URI = " \
    file://${OPENEULER_LOCAL_NAME} \
    file://hibot_fix.patch \
"

S = "${WORKDIR}/component_hibot"

DEPENDS += "hibot-user-driver"

inherit cmake

LDFLAGS += "-Wl,--no-as-needed"

do_install() {
    install -d ${D}${libdir}
    install -m 644 ${WORKDIR}/build/libhibot.so ${D}${libdir}
}

FILES:${PN} += " \
    ${libdir} \
"

FILES:${PN}-dev = ""

SUMMARY = "mcu tool"
LICENSE = "MulanPSL-2.0"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MulanPSL-2.0;md5=74b1b7a7ee537a16390ed514498bf23c"

SRC_URI = " \
    file://mcu_tool/mcu_tool.c \
"

S = "${WORKDIR}/mcu_tool"

do_compile() {
    ${CC} ${S}/mcu_tool.c -o ${S}/mcu_tool
}

do_install() {
    install -d ${D}/sbin
    install -m 755 ${S}/mcu_tool ${D}/sbin
}

FILES:${PN} = " /sbin/mcu_tool "

INHIBIT_PACKAGE_STRIP = "1"

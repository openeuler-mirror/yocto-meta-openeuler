SUMMARY = "soft i2c driver"
LICENSE = "GPL"
LIC_FILES_CHKSUM = "file://i2c_soft.c;beginline=373;endline=373;md5=787eb329e3eac3e58f47744d2cf33699"

SRC_URI = " \
    file://i2c_soft/i2c_soft.c \
    file://i2c_soft/Makefile \
"

S = "${WORKDIR}/i2c_soft"

inherit module

do_compile() {
    oe_runmake
}

do_install() {
    install -d ${D}/ko
    install -m 644 ${S}/i2c_soft.ko ${D}/ko
}

FILES:${PN} = " /ko/i2c_soft.ko "

INHIBIT_PACKAGE_STRIP = "1"

SUMMARY = "ch343 driver"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://ch343.c;beginline=2469;endline=2469;md5=787eb329e3eac3e58f47744d2cf33699"

SRC_URI = " \
    file://ch343/ch343.h \
    file://ch343/ch343.c \
    file://ch343/Makefile \
"

S = "${WORKDIR}/ch343"

inherit module

do_compile() {
    oe_runmake
}

do_install() {
    install -d ${D}/ko
    install -m 644 ${S}/ch343.ko ${D}/ko
}

FILES:${PN} = " /ko/ch343.ko "

INHIBIT_PACKAGE_STRIP = "1"

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI:append:rk3568 = " file://interfaces_rk3568 \
"

do_install:append:rk3568 () {
    install -m 0644 ${WORKDIR}/interfaces_rk3568 ${D}${sysconfdir}/network/interfaces
}

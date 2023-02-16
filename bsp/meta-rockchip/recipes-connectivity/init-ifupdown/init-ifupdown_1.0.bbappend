FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"
SRC_URI_append_ok3568 = " file://interfaces_ok3568 "
do_install_append_ok3568 () {
    install -m 0644 ${WORKDIR}/interfaces_ok3568 ${D}${sysconfdir}/network/interfaces
}
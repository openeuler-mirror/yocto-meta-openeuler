# adapted for hi1711
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI:append = " file://0001-mica_main-set-phy_shared_mem-to-0x90000000.patch"

# install uniproton in /firmware/
do_install:append (){
    install -d ${D}/firmware

    install -D ${S}/rpmsg_pty_demo/Uniproton_hi3093.bin ${D}/firmware/
}

FILES:${PN} += "/firmware"

# adapted for ok3568
EXTRA_OECMAKE = " \
	-DDEMO_TARGET=openamp_demo \
	"
do_install_append(){
    install -d ${D}/firmware

    install -D ${S}/openamp_demo/rtthread-ok3568.bin ${D}/firmware/
}

FILES_${PN} += "/firmware"
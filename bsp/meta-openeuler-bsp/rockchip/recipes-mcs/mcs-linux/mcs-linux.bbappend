# adapted for ok3568
EXTRA_OECMAKE = " \
	-DDEMO_TARGET=openamp_demo \
	"
do_install:append(){
    install -d ${D}/firmware

    install -D ${S}/openamp_demo/rtthread-ok3568.bin ${D}/firmware/
}

FILES:${PN} += "/firmware"
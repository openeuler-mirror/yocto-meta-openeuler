# adapted for ok3568
EXTRA_OECMAKE = " \
	-DDEMO_TARGET=openamp_demo \
	"
do_install_append(){
    cp ${B}/openamp_demo/rtthread-ok3568.bin ${D}/firmware/
}

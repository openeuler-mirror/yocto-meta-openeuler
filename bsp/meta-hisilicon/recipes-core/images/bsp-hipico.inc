# add bsp depends here, should use for all images(tiny, standard, etc)

IMAGE_INSTALL:append = " \
hipico-bsp-pkg \
"

set_virtual_uart_login() {
    if [ -e ${IMAGE_ROOTFS}/etc/inittab ];then
		echo "::respawn:/sbin/getty -L ttyGS0 115200 vt100 -n root -I \"Auto login as root ...\"" >> ${IMAGE_ROOTFS}/etc/inittab
    fi
}

IMAGE_PREPROCESS_COMMAND:append = "set_virtual_uart_login;"

add_lib_soft_link() {
    if [ -d ${IMAGE_ROOTFS}/lib/ ];then
		cd ${IMAGE_ROOTFS}/lib/
		ln -sf libsecurec.so.1.0  libsecurec.so 
		ln -sf libmp3_enc.so.1.0  libmp3_enc.so 
		ln -sf libmp3_lame.so.1.0 libmp3_lame.so 
		ln -sf libmp3_dec.so.1.0  libmp3_dec.so
		ln -sf libsvp_aicpu.so.1.0 libsvp_aicpu.so
		cd -
    fi
}

IMAGE_PREPROCESS_COMMAND:append = "add_lib_soft_link;"



do_install_append(){
    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)};then
        install -d ${D}${sysconfdir}/wpa_supplicant
        install -m 600 ${WORKDIR}/wpa_supplicant.conf ${D}${sysconfdir}/wpa_supplicant/wpa_supplicant-mlan0.conf
    fi
}
# The kp920 does not configure static ip by default
do_install:append() {
        ## systemd related basic configuration
        if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
                rm ${D}${sysconfdir}/systemd/network/10-eth-static.network
        fi
}

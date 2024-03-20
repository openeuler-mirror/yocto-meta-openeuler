FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI = "file://config.txt \
"
S = "${WORKDIR}"

do_deploy:append() {
    # change configs to use uefi and load mcs dtoverlay if enable mcs DISTRO_FEATURES
    if ${@bb.utils.contains('DISTRO_FEATURES', 'mcs', 'true', 'false', d)}; then
        echo "arm_64bit=1" >> ${CONFIG}
        echo "uart_2ndstage=1" >> ${CONFIG}
        echo "enable_gic=1" >> ${CONFIG}
        echo "armstub=RPI_EFI.fd" >> ${CONFIG}
        echo "disable_commandline_tags=1" >> ${CONFIG}
        echo "disable_overscan=1" >> ${CONFIG}
        echo "device_tree_address=0x1f0000" >> ${CONFIG}
        echo "device_tree_end=0x200000" >> ${CONFIG}

        # if openamp as MCS_FEATURES, add mcs-resources to config.txt
        if ${@bb.utils.contains('MCS_FEATURES', 'openamp', 'true', 'false', d)}; then
            echo "dtoverlay=mcs-resources" >> ${CONFIG}
        fi

        # if jailhouse as MCS_FEATURES, add jailhouse-overlay to config.txt
        if ${@bb.utils.contains('MCS_FEATURES', 'jailhouse', 'true', 'false', d)}; then
            echo "dtoverlay=jailhouse-overlay" >> ${CONFIG}
        fi
    fi
}

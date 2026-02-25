FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# To do: mcs support.
# require ${@bb.utils.contains('DISTRO_FEATURES', 'mcs', 'mcs.inc', '', d)}
# require ${@bb.utils.contains('BUILD_GUEST_OS', '1', 'initrd-install.inc', '', d)}

systemd_preset_all:prepend() {
    # use NetworkManager if exist
    SRV_FILE_NETWORK_MANAGER="${IMAGE_ROOTFS}${root_prefix}/usr/lib/systemd/system/NetworkManager.service"
    if [ -e "${SRV_FILE_NETWORK_MANAGER}" ]; then
	SYSTEMD_PRESET_FILE="${IMAGE_ROOTFS}${root_prefix}/lib/systemd/system-preset/90-systemd.preset"
	if [ -f "${SYSTEMD_PRESET_FILE}" ]; then
	    # disable systemd-networkd
            sed -i \
	        -e 's/^enable systemd-networkd.service/disable systemd-networkd.service/' \
	        -e 's/^enable systemd-network-generator.service/disable systemd-network-generator.service/' \
	        "${SYSTEMD_PRESET_FILE}"
	fi
	DHCPCD_PRESET_FILE="${IMAGE_ROOTFS}${root_prefix}/lib/systemd/system-preset/98-dhcpcd.preset"
	if [ -f "${DHCPCD_PRESET_FILE}" ]; then
	    # disable dhcpcd preset
            sed -i 's/^enable dhcpcd.service/disable dhcpcd.service/' "${DHCPCD_PRESET_FILE}"
	fi
        # enable NetworkManager
	NEW_PRESET_FILE="${IMAGE_ROOTFS}${root_prefix}/lib/systemd/system-preset/90-networkmanager.preset"
	echo "enable NetworkManager.service" > "${NEW_PRESET_FILE}"
	chmod 0644 "${NEW_PRESET_FILE}"
    fi
}

delete_unneeded_and_make_first_boot() {
    set -x
    test -d "${OUTPUT_DIR}" || mkdir -p "${OUTPUT_DIR}"
    rm -rf "${OUTPUT_DIR}"/*
    cd "${IMAGE_ROOTFS}"
    if [ "$(ls boot)" ]; then
        cp -r boot/* "${OUTPUT_DIR}"
        # just need the boot dir, others in boot are not needed to reduce the size of image.
        rm -rf ./boot/*
    fi

    # if npu driver provide svm.ko, use the one from npu driver, not kernel itself.
    if [ -e var/Ascend/install_cache/svm.ko ];then 
        if [ -e lib/modules/5.10.0-openeuler/kernel/drivers/char/svm.ko ];then 
            cp -f var/Ascend/install_cache/svm.ko lib/modules/5.10.0-openeuler/kernel/drivers/char/svm.ko
        fi
    fi

    # for first boot
    echo "bash /sbin/init_once.sh" >> etc/profile

    # prepare ext dir
    mkdir -p etc/ld.so.conf.d
    mkdir -p usr/lib/itrustee_ta
    mkdir -p etc/sharepool
    mkdir -p usr/local/sbin
    mkdir -p etc/modules-load.d
    mkdir -p usr/local/include
    mkdir -p home/package
    mkdir -p usr/local/mindx
    cp etc/ascend_install.info var/Ascend/install_cache/

    cd -
    set +x
}
IMAGE_PREPROCESS_COMMAND += "${@bb.utils.contains('DISTRO_FEATURES', '3591fullimg', 'delete_unneeded_and_make_first_boot;', '', d)}"

copy_3591img_distro() {
    set -x
    mkdir -p ${OUTPUT_DIR}
    for IMAGETYPE in ${IMAGE_FSTYPES}
    do
        rm -f "${OUTPUT_DIR}"/${IMAGE_NAME}${IMAGE_NAME_SUFFIX%.rootfs}.*${IMAGETYPE}
        cp -fp ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX%.rootfs}.*${IMAGETYPE} ${OUTPUT_DIR}/
    done
    set +x
}

IMAGE_POSTPROCESS_COMMAND += "${@bb.utils.contains('DISTRO_FEATURES', '3591fullimg', 'copy_3591img_distro;', '', d)}"

copy_3591ebl_distro() {
    set -x
    EBL_SUFIX="-ebl."
    mkdir -p ${OUTPUT_DIR}
    for IMAGETYPE in ${IMAGE_FSTYPES}
    do
        rm -f "${OUTPUT_DIR}"/${IMAGE_NAME}${IMAGE_NAME_SUFFIX%.rootfs}.*${IMAGETYPE}
        cp -fp ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX%.rootfs}.*${IMAGETYPE} ${OUTPUT_DIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX%.rootfs}${EBL_SUFIX}${IMAGETYPE}
    done
    set +x
}

IMAGE_POSTPROCESS_COMMAND:append = "${@bb.utils.contains('DISTRO_FEATURES', '3591ebl', 'copy_3591ebl_distro;', '', d)}"

DESCRIPTION = "Some pre-compiled ko, firmware and initscripts for 3591rc"
LICENSE = "CLOSED"

DEPENDS = "update-rc.d-native linux-openeuler"
RDEPENDS:${PN} = " libyaml bash-completion "

DRIVER_RUN_FILE = "${@bb.utils.contains('DISTRO_FEATURES', '3591b', 'Hi3591B-driver-7.7.0.1.231-openEuler24.03.aarch64-rc-spc001.run', 'Hi3591P-driver-7.7.0.1.231-openEuler24.03.aarch64-rc-spc001.run', d)}"

SRC_URI = " \
    file://3591rc/${DRIVER_RUN_FILE} \
    file://ascend-bsp.service \
    file://launch3591b.sh \
    file://launch3591p.sh \
    file://emmc-head \
"

LAUNCHFILE = "${@bb.utils.contains('DISTRO_FEATURES', '3591b', 'launch3591b.sh', 'launch3591p.sh', d)}"

# SRC_URI[sha256sum] = "52657da2f4eceb83f94a70b96106b2c3449cfcf0f4fb5cba6fdc65b807e96a9b"

S = "${WORKDIR}/bsp"

MAKE_EMMC_HEAD = "${@bb.utils.contains('DISTRO_FEATURES', '3591fullimg', 'true', 'false', d)}"
PRODUCT_OUTPUT_NAME = "${@bb.utils.contains('DISTRO_FEATURES', '3591b', '3591b', '3591p', d)}"

INSANE_SKIP:${PN} += "already-stripped"
FILES:${PN} = "${sysconfdir} ${systemd_system_unitdir} /etc /var /fw /usr /home"

do_compile () {
    if [ ! -f ${WORKDIR}/3591rc/${DRIVER_RUN_FILE} ];then
        bberror "${DRIVER_RUN_FILE} not exist, please put it here first"
    fi
    if [ -d ${S}/install_cache ];then
        rm -rf ${S}/install_cache
    fi
    bash ${WORKDIR}/3591rc/${DRIVER_RUN_FILE} --noexec --extract=${S}/install_cache
}

do_install () {
    install -d ${D}/var/Ascend/install_cache
    install -d ${D}/fw
    install -d ${D}/etc
    install -d ${D}/usr/local/scripts
    install -d ${D}/${systemd_system_unitdir}
    cp ${S}/install_cache/scripts/minirc_boot.sh ${D}/var
    cp ${S}/install_cache/firmware/* ${D}/fw
    cp -rf ${S}/install_cache/* ${D}/var/Ascend/install_cache/

    # mkInstallInfo -- ref: sdtool/make_os_sd.sh
    Driver_Install_Path_Param="/var/davinci"
    Driver_Install_For_All="no"
    Driver_Install_Mode="normal"
    Driver_Install_Type="full"
    echo "UserName=HwHiAiUser
UserGroup=HwHiAiUser
Driver_Install_Path_Param=$Driver_Install_Path_Param
Driver_Install_For_All=$Driver_Install_For_All
Driver_Install_Mode=$Driver_Install_Mode
Driver_Install_Type=$Driver_Install_Type" > ${D}/etc/ascend_install.info

    # setStartDavinciService
    # cp ${S}/install_cache/scripts/start_davinci.sh ${D}/usr/local/scripts/
    # cp ${S}/install_cache/scripts/start-davinci.service ${D}/${systemd_system_unitdir}

    # configFstab
    install -d ${D}/home/log
    install -d ${D}/home/data
    
    # config310BJournald: use oee's default log config
    # config310BforUbuntuSshdKeyGen: use oee's default log config
    # config310BLogind: imp by oee init_once.sh

    install -d ${D}${sysconfdir}/init.d
    install -m 0755 ${WORKDIR}/${LAUNCHFILE} ${D}${sysconfdir}/init.d/launch3591rc.sh
    has_systemd="${@bb.utils.contains('DISTRO_FEATURES', 'systemd', 'True', 'False', d)}"
    if [ $has_systemd = "True" ]; then
        install -d ${D}/${systemd_system_unitdir}
        install -m 0644 ${WORKDIR}/ascend-bsp.service  ${D}/${systemd_system_unitdir}
        # this serivce should launch after init_once.sh done, so do not place it in /etc/systemd/system
    fi

    # mkae partition_head_info and boot_image_info
    if [ ${MAKE_EMMC_HEAD} == "true" ];then
        haed_info_workdir="${WORKDIR}/haed_info_workspace"
        mkdir -p ${haed_info_workdir}
        cp -f ${DEPLOY_DIR_IMAGE}/${PRODUCT_OUTPUT_NAME}-dt.img ${haed_info_workdir}/dt.img
        cp -f ${DEPLOY_DIR_IMAGE}/${PRODUCT_OUTPUT_NAME}-kernel ${haed_info_workdir}/Image
        cp -f ${D}/fw/itrustee.img ${haed_info_workdir}/
	cd ${haed_info_workdir}/
        ${WORKDIR}/emmc-head ./ /dev/nvme0n1p1 /dev/nvme0n1p1
        install -m 0644 ${haed_info_workdir}/boot_image_info ${DEPLOY_DIR_IMAGE}/boot_image_info_nvme0p1p1
        install -m 0644 ${haed_info_workdir}/parttion_head_info ${DEPLOY_DIR_IMAGE}/parttion_head_info_nvme0p1p1
        ${WORKDIR}/emmc-head ./ /dev/nvme0n1p1 /dev/nvme0n1p2
        install -m 0644 ${haed_info_workdir}/boot_image_info ${DEPLOY_DIR_IMAGE}/boot_image_info_nvme0p1p2
        install -m 0644 ${haed_info_workdir}/parttion_head_info ${DEPLOY_DIR_IMAGE}/parttion_head_info_nvme0p1p2
        ${WORKDIR}/emmc-head ./ /dev/mmcblk0p1 /dev/mmcblk0p1
        install -m 0644 ${haed_info_workdir}/boot_image_info ${DEPLOY_DIR_IMAGE}/boot_image_info_mmc0p1p1
        install -m 0644 ${haed_info_workdir}/parttion_head_info ${DEPLOY_DIR_IMAGE}/parttion_head_info_mmc0p1p1
        ${WORKDIR}/emmc-head ./ /dev/mmcblk0p1 /dev/mmcblk0p2
        install -m 0644 ${haed_info_workdir}/boot_image_info ${DEPLOY_DIR_IMAGE}/boot_image_info_mmc0p1p2
        install -m 0644 ${haed_info_workdir}/parttion_head_info ${DEPLOY_DIR_IMAGE}/parttion_head_info_mmc0p1p2
        ${WORKDIR}/emmc-head ./ /dev/mmcblk1p1 /dev/mmcblk1p1
        install -m 0644 ${haed_info_workdir}/boot_image_info ${DEPLOY_DIR_IMAGE}/boot_image_info_mmc1p1p1
        install -m 0644 ${haed_info_workdir}/parttion_head_info ${DEPLOY_DIR_IMAGE}/parttion_head_info_mmc1p1p1
        ${WORKDIR}/emmc-head ./ /dev/mmcblk1p1 /dev/mmcblk1p2
        install -m 0644 ${haed_info_workdir}/boot_image_info ${DEPLOY_DIR_IMAGE}/boot_image_info_mmc1p1p2
        install -m 0644 ${haed_info_workdir}/parttion_head_info ${DEPLOY_DIR_IMAGE}/parttion_head_info_mmc1p1p2
	cd -
    fi

}

SYSROOT_DIRS += "/fw"
SYSROOT_PREPROCESS_FUNCS += "additional_populate_sysroot"
additional_populate_sysroot() {
    sysroot_stage_dir ${D}/fw ${SYSROOT_DESTDIR}/fw
}

PRIVATE_LIBS = "libpfstat_base.so libhiperf.so libpfstat_base.so "

INHIBIT_PACKAGE_STRIP = "1"
INHIBIT_SYSROOT_STRIP = "1"

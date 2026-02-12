DESCRIPTION = "use yocto to re-compile mpp sample for hieulerpi1, just for kernel 6.6"
SECTION = "mpp sample"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=1748ada63ab6140110ad5ed27a8b8d18"

OPENEULER_LOCAL_NAME = "HiEuler-mpp-sample-kernel6"

SRC_URI = " \
        file://HiEuler-mpp-sample-kernel6 \
"

S = "${WORKDIR}/HiEuler-mpp-sample-kernel6"

inherit module oee-archive

do_compile() {
    cd ${S}/src
    sed -i 's/aarch64-openeuler-linux-gnu-/aarch64-openeuler-linux-/' Makefile.param
	
    install -d ${S}/src/vio/imx347
    install -d ${S}/src/vio/os04a10
    install -d ${S}/src/vio/os08a20
    install -d ${S}/src/vio/sc450ai
    cd ${S}/src/vio
    export SENSOR0_TYPE=SONY_IMX347_SLAVE_MIPI_4M_30FPS_12BIT
    export SENSOR1_TYPE=SONY_IMX347_SLAVE_MIPI_4M_30FPS_12BIT
    export SENSOR2_TYPE=SONY_IMX347_SLAVE_MIPI_4M_30FPS_12BIT
    export SENSOR3_TYPE=SONY_IMX347_SLAVE_MIPI_4M_30FPS_12BIT
    oe_runmake clean
    oe_runmake
    mv sample_vio ${S}/src/vio/imx347
    export SENSOR0_TYPE=OV_OS04A10_MIPI_4M_30FPS_12BIT
    export SENSOR1_TYPE=OV_OS04A10_MIPI_4M_30FPS_12BIT
    export SENSOR2_TYPE=OV_OS04A10_MIPI_4M_30FPS_12BIT
    export SENSOR3_TYPE=OV_OS04A10_MIPI_4M_30FPS_12BIT
    oe_runmake clean
    oe_runmake
    mv sample_vio ${S}/src/vio/os04a10
	export SENSOR0_TYPE=OV_OS08A20_MIPI_8M_30FPS_12BIT
    export SENSOR1_TYPE=OV_OS08A20_MIPI_8M_30FPS_12BIT
    export SENSOR2_TYPE=OV_OS08A20_MIPI_8M_30FPS_12BIT
    export SENSOR3_TYPE=OV_OS08A20_MIPI_8M_30FPS_12BIT
    oe_runmake clean
    oe_runmake
    mv sample_vio ${S}/src/vio/os08a20
    export SENSOR0_TYPE=SC450AI_MIPI_4M_30FPS_10BIT
    export SENSOR1_TYPE=SC450AI_MIPI_4M_30FPS_10BIT
    export SENSOR2_TYPE=SC450AI_MIPI_4M_30FPS_10BIT
    export SENSOR3_TYPE=SC450AI_MIPI_4M_30FPS_10BIT
    oe_runmake clean
    oe_runmake
    mv sample_vio ${S}/src/vio/sc450ai
	export SENSOR0_TYPE=SC450AI_2L_MIPI_2M_30FPS_10BIT
    export SENSOR1_TYPE=SC450AI_2L_MIPI_2M_30FPS_10BIT
    export SENSOR2_TYPE=SC450AI_2L_MIPI_2M_30FPS_10BIT
    export SENSOR3_TYPE=SC450AI_2L_MIPI_2M_30FPS_10BIT
    oe_runmake clean
    oe_runmake
    mv sample_vio ${S}/src/vio/sc450ai/sample_vio_4x2lane_2M
	export SENSOR0_TYPE=SC450AI_2L_MIPI_4M_30FPS_10BIT
    export SENSOR1_TYPE=SC450AI_2L_MIPI_4M_30FPS_10BIT
    export SENSOR2_TYPE=SC450AI_2L_MIPI_4M_30FPS_10BIT
    export SENSOR3_TYPE=SC450AI_2L_MIPI_4M_30FPS_10BIT
    oe_runmake clean
    oe_runmake
    mv sample_vio ${S}/src/vio/sc450ai/sample_vio_4x2lane_4M
    oe_runmake clean

    cd ${S}/src
    export SENSOR0_TYPE=SONY_IMX347_SLAVE_MIPI_4M_30FPS_12BIT
    export SENSOR1_TYPE=SONY_IMX347_SLAVE_MIPI_4M_30FPS_12BIT
    export SENSOR2_TYPE=SONY_IMX347_SLAVE_MIPI_4M_30FPS_12BIT
    export SENSOR3_TYPE=SONY_IMX347_SLAVE_MIPI_4M_30FPS_12BIT
    oe_runmake
    cd ${S}/src/host_uvc
    oe_runmake
    cd -
}

do_install () {
    mkdir -p ${S}/deploy/{include,lib}
    cp -a ${S}/include/hisilicon/* ${S}/deploy/include
	cp -a ${S}/include/3rdparty/* ${S}/deploy/include
    cp -a ${S}/lib/gcc/hisilicon/* ${S}/deploy/lib
    cp -a ${S}/lib/gcc/3rdparty/* ${S}/deploy/lib
    cd ${S}/deploy
    tar czf include.tar.gz include/
    tar caf lib.tar.gz lib/

    install -d ${D}/opt/sample/mipi_rx/imx347
    install -d ${D}/opt/sample/mipi_rx/os04a10
    install -d ${D}/opt/sample/mipi_rx/os08a20
    install -d ${D}/opt/sample/mipi_rx/sc450ai
    install -m 0755 ${S}/src/vio/imx347/sample_vio ${D}/opt/sample/mipi_rx/imx347
    install -m 0755 ${S}/src/vio/os04a10/sample_vio ${D}/opt/sample/mipi_rx/os04a10
    install -m 0755 ${S}/src/vio/os08a20/sample_vio ${D}/opt/sample/mipi_rx/os08a20
    install -m 0755 ${S}/src/vio/sc450ai/sample_vio ${D}/opt/sample/mipi_rx/sc450ai
    install -m 0755 ${S}/src/vio/sc450ai/sample_vio_4x2lane_2M ${D}/opt/sample/mipi_rx/sc450ai
    install -m 0755 ${S}/src/vio/sc450ai/sample_vio_4x2lane_4M ${D}/opt/sample/mipi_rx/sc450ai

    install -d ${D}/opt/sample/audio
    install -m 0755 ${S}/src/audio/sample_audio ${D}/opt/sample/audio

    install -d ${D}/opt/sample/uvc
    install -m 0755 ${S}/src/host_uvc/sample_uvc ${D}/opt/sample/uvc

    install -d ${D}/opt/sample/mipi_tx
    install -m 0755 ${S}/src/vdec/sample_vdec ${D}/opt/sample/mipi_tx

    rm -rf ${S}/src/vio/imx347 ${S}/src/vio/os04a10 ${S}/src/vio/os08a20 ${S}/src/vio/sc450ai
    install -d ${D}/root/sample
    find ${S}/src -type f -executable ! -name "*.so*" ! -name "*.a" ! -name "*.o" ! -name "*.c" ! -name "*.cpp" ! -name "Makefile" \
        | xargs -I {} install -m 0755 {} ${D}/root/sample
    cd -
}

do_deploy[nostamp] = "1"
do_deploy() {
    install -d ${DEPLOY_DIR}/third_party_sdk
    install -m 0644 ${S}/deploy/include.tar.gz ${DEPLOY_DIR}/third_party_sdk
    install -m 0644 ${S}/deploy/lib.tar.gz ${DEPLOY_DIR}/third_party_sdk
}

FILES:${PN} = " /root/sample /opt/sample "

INHIBIT_PACKAGE_STRIP = "1"

addtask deploy after do_install
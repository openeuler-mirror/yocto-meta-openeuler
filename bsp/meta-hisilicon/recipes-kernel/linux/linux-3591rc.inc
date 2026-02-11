# add recipes-kernel path to find patch and defconfig
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

# for mkimage
DEPENDS += "u-boot-tools-native dtc-native"

KERNEL_VERSION_SANITY_SKIP = "1"

# not support kernel6 now for 3591
OPENEULER_REPO_NAMES = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
        not-support-kernel6-for-3591 \
    ', ' \
        kernel-5.10-tag3591 \
    ', d)} \
"

PV = "${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', 'not-support-kernel6-for-3591', '5.10-tag3591', d)}"

PRODUCT_NAME = "${@bb.utils.contains('DISTRO_FEATURES', '3591b', 'aaaaaa310Brc', 'aaaaaa310prc', d)}"
PRODUCT_PLATFORM_NAME = "${@bb.utils.contains('DISTRO_FEATURES', '3591b', 'hi1910Brc', 'hi1910p', d)}"
PRODUCT_OUTPUT_NAME = "${@bb.utils.contains('DISTRO_FEATURES', '3591b', '3591b', '3591p', d)}"


SRC_URI:append = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
	 \
    ', ' \
        file://patch/3591rc/0001-add-3591-bsp-depends.patch \
	file://patch/3591rc/0001-add-3591b-net-support-ascend-milan-support-hns3.patch \
        file://patch/3591rc/0002-add-securec-source-for-3591.patch \
        file://patch/3591rc/0001-add-cert-for-3591.patch \
        file://patch/3591rc/make_oee_ko_compat.patch \
    ', d)} \
    file://dtbs/3591rc \
    file://tools/3591rc \
    file://patch/0001-Support-Orange-Pi-Ai-Pro.patch.gz;apply=yes \
    file://patch/0003-fix-orangepiai-oee-rtl8811cu-build-err.patch \
"

# remove default patch
SRC_URI:remove = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'kernel6', ' \
        file://patches/${ARCH}/0001-kernel6.6-arm64-add-zImage-support-for-arm64.patch \
    ', ' \
        file://patches/${ARCH}/0001-arm64-add-zImage-support-for-arm64.patch \
    ', d)} \
"

# use yocto's defconfig file
OPENEULER_KERNEL_CONFIG = "${@bb.utils.contains('DISTRO_FEATURES', '3591b', 'file://config/3591rc/3591b_defconfig', 'file://config/3591rc/3591p_defconfig', d)}"

# for in-tree defconfig
KBUILD_DEFCONFIG = ""

# select target board: 
# current support :
# b: orange-pi-8t orange-pi-20t
# p: runhe-3591prc ema-3591prc-96g

# default if 3591b use orange-pi-20t and 3591p use runhe-3591prc
TARGET_BOARD ?= "${@bb.utils.contains('DISTRO_FEATURES', '3591b', 'orange-pi-20t', 'runhe-3591prc', d)}"

do_compile:append(){

    # select dts according to TARGET_BOARD
    if [ ${TARGET_BOARD} == "orange-pi-20t" ];then
        cp -f ${WORKDIR}/dtbs/3591rc/dts/orange-pi-20t.dts ${WORKDIR}/dtbs/3591rc/dts/hi1910b/hi1910BL/hi1910B-default.dts
    elif [ ${TARGET_BOARD} == "orange-pi-8t" ];then
        cp -f ${WORKDIR}/dtbs/3591rc/dts/orange-pi-8t.dts ${WORKDIR}/dtbs/3591rc/dts/hi1910b/hi1910BL/hi1910B-default.dts
    elif [ ${TARGET_BOARD} == "runhe-3591prc" ];then
        cp -f ${WORKDIR}/dtbs/3591rc/dts/runhe-3591prc.dts ${WORKDIR}/dtbs/3591rc/dts/helper/hi1910P-default.dts
    elif [ ${TARGET_BOARD} == "ema-310prc-96g" ];then
        cp -f ${WORKDIR}/dtbs/3591rc/dts/ema-3591prc-96g.dts ${WORKDIR}/dtbs/3591rc/dts/helper/hi1910P-default.dts
    fi

    # build dt.img
    mkdir -p ${WORKDIR}/dtbs/3591rc/dtbtool/tmp ${WORKDIR}/dtbs/3591rc/abl/libc_sec/src ${WORKDIR}/dtbs/3591rc/abl/libc_sec/include
    rm -rf ${WORKDIR}/dtbs/3591rc/dtbtool/tmp ${WORKDIR}/dtbs/3591rc/abl/libc_sec/src ${WORKDIR}/dtbs/3591rc/abl/libc_sec/include
    mkdir -p ${WORKDIR}/dtbs/3591rc/dtbtool/tmp ${WORKDIR}/dtbs/3591rc/abl/libc_sec/include
    cp -rf ${STAGING_KERNEL_DIR}/drivers/hisi/securec/src/ ${WORKDIR}/dtbs/3591rc/abl/libc_sec
    cp -f ${STAGING_KERNEL_DIR}/drivers/hisi/securec/src/securec.h ${WORKDIR}/dtbs/3591rc/abl/libc_sec/include
    cp -f ${STAGING_KERNEL_DIR}/drivers/hisi/securec/src/securectype.h ${WORKDIR}/dtbs/3591rc/abl/libc_sec/include
    cd ${WORKDIR}/dtbs/3591rc/dtbtool/tmp
    CC=/usr/bin/gcc LD=/usr/bin/ld CXX=/usr/bin/g++ cmake .. -DTOP_DIR=${WORKDIR}/dtbs/3591rc -DPRODUCT=${PRODUCT_NAME} && make device_dtb
    cd -

    # prepare sign tools
    HEADER_VERSION="1.1.1.1.1"
    esbc_header_tool="${WORKDIR}/tools/3591rc/signtool/esbc_header/esbc_header.py"
    image_pack_tool="${WORKDIR}/tools/3591rc/signtool/image_pack/image_pack.py"

    # sign dtimg
    dtimg_file="${WORKDIR}/dtbs/3591rc/dtbtool/tmp/dt.img"
    python3 ${esbc_header_tool} -raw_img $dtimg_file -out_img $dtimg_file -version $HEADER_VERSION -nvcnt 0 -tag dtimg -platform ${PRODUCT_PLATFORM_NAME}
    python3 ${image_pack_tool} -raw_img $dtimg_file -out_img $dtimg_file -platform ${PRODUCT_PLATFORM_NAME} -version $HEADER_VERSION
    cp -f $dtimg_file ${KERNEL_OUTPUT_DIR}/${PRODUCT_OUTPUT_NAME}-dt.img

    # sign kernel
    image_file="${WORKDIR}/dtbs/3591rc/dtbtool/tmp/Image"
    cp ./arch/arm64/boot/Image $image_file
    python3 ${esbc_header_tool} -raw_img $image_file -out_img $image_file -version $HEADER_VERSION -nvcnt 0 -tag uimage -platform ${PRODUCT_PLATFORM_NAME}
    python3 ${image_pack_tool} -raw_img $image_file -out_img $image_file -platform ${PRODUCT_PLATFORM_NAME} -version $HEADER_VERSION
    cp -f $image_file ${KERNEL_OUTPUT_DIR}/${PRODUCT_OUTPUT_NAME}-kernel

}

do_install:append() {
    install -d ${DEPLOY_DIR_IMAGE}
    install -m 0644 ${KERNEL_OUTPUT_DIR}/${PRODUCT_OUTPUT_NAME}-dt.img ${DEPLOY_DIR_IMAGE}
    install -m 0644 ${KERNEL_OUTPUT_DIR}/${PRODUCT_OUTPUT_NAME}-kernel ${DEPLOY_DIR_IMAGE}
    install -d ${OUTPUT_DIR}
    install -m 0644 ${KERNEL_OUTPUT_DIR}/${PRODUCT_OUTPUT_NAME}-dt.img ${OUTPUT_DIR}
    install -m 0644 ${KERNEL_OUTPUT_DIR}/${PRODUCT_OUTPUT_NAME}-kernel ${OUTPUT_DIR}
}


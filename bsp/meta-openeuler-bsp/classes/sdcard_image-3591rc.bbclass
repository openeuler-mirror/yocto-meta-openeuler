inherit image_types

# This image depends on the rootfs image
IMAGE_TYPEDEP:3591-sdimg = "${SDIMG_ROOTFS_TYPE}"

SDIMG_ROOTFS_TYPE ?= "ext4"
SDIMG_ROOTFS = "${IMGDEPLOYDIR}/${IMAGE_LINK_NAME}.${SDIMG_ROOTFS_TYPE}"

# For the names of kernel artifacts
inherit kernel-artifact-names

do_image_3591_sdimg[depends] = " \
    parted-native:do_populate_sysroot \
    mtools-native:do_populate_sysroot \
    dosfstools-native:do_populate_sysroot \
    virtual/kernel:do_deploy \
    3591-bsp-pkg:do_populate_sysroot \
"
#rpi-bootfiles:do_deploy 

do_image_3591_sdimg[recrdeps] = "do_build"

# SD card image name
SDIMG = "${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.3591-sdimg"

PRODUCT_OUTPUT_NAME = "${@bb.utils.contains('DISTRO_FEATURES', '3591b', '3591b', '3591p', d)}"

IMAGE_CMD:3591-sdimg () {
    # sector size must set to 512
    SECTOR_SIZE="512"

    # RSV for p1, need keep ROOT AS p2 partition.
    RSV_START="559104"
    RSV_SIZE="2048"
    RSV_END=$(expr ${RSV_START} + ${RSV_SIZE} - 1)

    # ROOTFS_SIZE is Kib, change to sector.
    ROOT_SIZE=$(awk "BEGIN {print int(${ROOTFS_SIZE} * 2 + 1)}")
    ROOT_START="561152"
    ROOT_END=$(expr ${ROOT_START} + ${ROOT_SIZE} - 1)

    BOOTIMG_OFFSET_A="32768"
    BOOTIMG_OFFSET_B="294912"
    IMAGE_OFFSET=0
    IMAGE_SIZE=61440
    #40M 2M
    DTB_OFFSET=81920
    DTB_SIZE=4096
    #44M 2M
    TEE_OFFSET=90112
    TEE_SIZE=4096

    sectorUnit="s"
    sectorEnd=$(expr ${ROOT_END} + 400)

    # Initialize sdcard image file
    dd if=/dev/zero of=${SDIMG} bs=512 count=${sectorEnd}

    # Create partition table
    parted ${SDIMG} -s mklabel gpt

    # juset one partition example:
    # if dd to nvme, use nvmep1p1
    # opt: _mmc0p1p1 _mmc0p1p2 _mmc1p1p1 _mmc1p1p2 _nvme0p1p1 _nvme0p1p2 , etc. 
    # ref: bsp/meta-hisilicon/recipes-bsp/ascend/3591-bsp-pkg.bb: mkae partition_head_info and boot_image_info
    BOOT_INFO_SUBFIX="_mmc1p1p1"

    # make part
    # parted ${SDIMG} -s mkpart primary ext2 $RSV_START$sectorUnit $RSV_END$sectorUnit
    parted ${SDIMG} -s mkpart primary ext4 $ROOT_START$sectorUnit $ROOT_END$sectorUnit

    # writeStructInfo
    #1M
    HEAD_OFFSET=2048
    #1M+64K
    HEAD_BAK_OFFSET=2176
    #1M+128K
    BOOTIMGDIR_OFFSET=2304
    #2M+128K
    BOOTCRL_OFFSET=4352

    dd if=${DEPLOY_DIR_IMAGE}/parttion_head_info${BOOT_INFO_SUBFIX} of=${SDIMG} conv=notrunc seek=$[HEAD_OFFSET] count=2 bs=$SECTOR_SIZE
    dd if=${DEPLOY_DIR_IMAGE}/parttion_head_info${BOOT_INFO_SUBFIX} of=${SDIMG} conv=notrunc seek=$[HEAD_BAK_OFFSET]  count=2 bs=$SECTOR_SIZE
    dd if=${DEPLOY_DIR_IMAGE}/boot_image_info${BOOT_INFO_SUBFIX} of=${SDIMG} conv=notrunc seek=$[BOOTIMGDIR_OFFSET] count=8 bs=$SECTOR_SIZE

    # Burn Partitions
    dd if=${DEPLOY_DIR_IMAGE}/${PRODUCT_OUTPUT_NAME}-kernel of=${SDIMG} conv=notrunc count=$IMAGE_SIZE seek=$[BOOTIMG_OFFSET_A+IMAGE_OFFSET] bs=$SECTOR_SIZE
    dd if=${DEPLOY_DIR_IMAGE}/${PRODUCT_OUTPUT_NAME}-dt.img of=${SDIMG} conv=notrunc count=$DTB_SIZE seek=$[BOOTIMG_OFFSET_A+DTB_OFFSET] bs=$SECTOR_SIZE
    dd if=${WORKDIR}/recipe-sysroot/fw/itrustee.img of=${SDIMG} conv=notrunc count=$TEE_SIZE seek=$[BOOTIMG_OFFSET_A+TEE_OFFSET] bs=$SECTOR_SIZE

    dd if=${DEPLOY_DIR_IMAGE}/${PRODUCT_OUTPUT_NAME}-kernel of=${SDIMG} conv=notrunc count=$IMAGE_SIZE seek=$[BOOTIMG_OFFSET_B+IMAGE_OFFSET] bs=$SECTOR_SIZE
    dd if=${DEPLOY_DIR_IMAGE}/${PRODUCT_OUTPUT_NAME}-dt.img of=${SDIMG} conv=notrunc count=$DTB_SIZE seek=$[BOOTIMG_OFFSET_B+DTB_OFFSET] bs=$SECTOR_SIZE
    dd if=${WORKDIR}/recipe-sysroot/fw/itrustee.img of=${SDIMG} conv=notrunc count=$TEE_SIZE seek=$[BOOTIMG_OFFSET_B+TEE_OFFSET] bs=$SECTOR_SIZE

    # If SDIMG_ROOTFS_TYPE is a .xz file use xzcat
    if echo "${SDIMG_ROOTFS_TYPE}" | egrep -q "*\.xz"
    then
        xzcat ${SDIMG_ROOTFS} | dd of=${SDIMG} conv=notrunc seek=$ROOT_START bs=$SECTOR_SIZE
    else
        dd if=${SDIMG_ROOTFS} of=${SDIMG} conv=notrunc seek=$ROOT_START bs=$SECTOR_SIZE
    fi
}


make_boot_intrd() {
    set -x
    test -d "${OUTPUT_DIR}" || mkdir -p "${OUTPUT_DIR}"
    rm -rf "${OUTPUT_DIR}"/*
    cd "${IMAGE_ROOTFS}"
    if [ -d ./tools-tmp ];then
        cp -f ./tools-tmp/bin/* ./bin
        cp -f ./tools-tmp/hi3093_init.sh ./
        cp -f ./tools-tmp/hi3093_upgrade.sh ./
        cp -f ./tools-tmp/link_emmc_devs ./
        rm -rf ./tools-tmp
    fi
    cp -fp ./boot/zImage ${OUTPUT_DIR}/ || true
    rm -f ./boot/Image* || true
    rm -f ./boot/zImage* || true
    rm -f ./boot/vmlinux* || true
    cp -f ${DEPLOY_DIR_IMAGE}/${INITRD_IMAGE_LIVE}*rootfs.cpio.gz ./boot/initrd_boot.cpio.gz
    cd -
    set +x
}
IMAGE_PREPROCESS_COMMAND:append = "make_boot_intrd;"

sign_copy_distro_3093() {
    set -x
    cd ${WORKDIR}/recipe-sysroot/signtools/build_sign
    EXT4CMS_FILE="Hi3093_ext4fs_cms.bin"
    EXT4_TARGET_BIN="Hi3093_ext4fs.img"
    if [ -e ${EXT4CMS_FILE} ]; then
        rm Hi3093_ext4fs_cms.bin
        rm Hi3093_ext4fs.img
        rm Hi3093_ext4fs.img.g1.cms
        rm Hi3093_ext4fs.img.g2.cms
        rm crldata_g1.crl
    fi
    cp -fp ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX%.rootfs}.*ext4 ${EXT4_TARGET_BIN}
    echo "Hi3093" >> Hi3093_ext4fs.img.g1.cms
    echo "Hi3093" >> Hi3093_ext4fs.img.g2.cms
    echo "Hi3093" >> crldata_g1.crl
    export KERNEL_VERSION_MAIN="5.10"
    ./generate_sign_image rootfs_cms.cfg
    dd if=Hi3093_ext4fs_cms.img of=Hi3093_ext4fs_cms.bin bs=1k count=36
    cp -fp ${EXT4_TARGET_BIN} ${OUTPUT_DIR}/
    cp -fp Hi3093_ext4fs_cms.bin ${OUTPUT_DIR}/
    cp -fp ${DEPLOY_DIR_IMAGE}/u-boot_rsa_4096.bin ${OUTPUT_DIR}/
    cp -fp ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX%.rootfs}.*cpio.gz ${OUTPUT_DIR}/
    cd -
    set +x
}
IMAGE_POSTPROCESS_COMMAND:append = "sign_copy_distro_3093;"

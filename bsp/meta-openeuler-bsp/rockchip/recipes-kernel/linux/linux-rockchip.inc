# add recipes-kernel path to find patch and defconfig
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

# add patch prebuild tools and logo
SRC_URI:remove = "file://patches/${ARCH}/0001-arm64-add-zImage-support-for-arm64.patch"

SRC_URI:append = " \
    file://patches/0000-rockchip-kernel.patch.gz;name=rockchip-kernel-patch \
    file://tools \
    file://logo \
"

INHIBIT_PACKAGE_STRIP = "1"

# patches for ryd-3568
SRC_URI:append:ryd-3568 = " \
    file://patches/0001-rk3568-8897-dts.patch \
    file://patches/0002-ryd-gpio-control.patch \
"

# patches for orangepi4-lts
SRC_URI:append:orangepi4-lts = " \
    file://patches/0001-add-dtb-for-rk3399-orangepi-4-lts.patch \
"

# mcs patch for ok3568 devicetree
SRC_URI:append = " \
    ${@bb.utils.contains('MCS_FEATURES', 'openamp', 'file://patches/0003-ok3568-support-mcs.patch', '', d)} \
"

# more support of device is coming. so we documented this patch md5sum.
SRC_URI[rockchip-kernel-patch.md5sum] = "8ee3af4d73b122ca17f536788e87cef6"

# add patch tool to solve patch apply
PATCHTOOL = "git"

OPENEULER_KERNEL_CONFIG = "file://config/${MACHINE}/${MACHINE}_defconfig"

# mkimg need use dtc command
DEPENDS += "dtc-native"

# add method to do_compile task to produce Rockchip specific bootable Image
do_compile:append:rk3568(){
    cp ../logo/* ./
    scripts/mkkrnlimg ${KERNEL_OUTPUT_DIR}/Image kernel.img
    ../tools/mkimg --dtb ${ROCKCHIP_KERNEL_DTB_NAME}
    sed -e "s:path_to_kernel:${WORKDIR}\/build:g" -e "s:dtb_name:${ROCKCHIP_KERNEL_DTB_NAME}:g" \
        ${WORKDIR}/tools/its_config > .tmp_its_config
    ../tools/mkimage -f .tmp_its_config -E -p 0x800 boot.img
    rm -rf .tmp_its_config
}

do_compile:append:rk3588(){
    cp ../logo/* ./
    scripts/mkkrnlimg ${KERNEL_OUTPUT_DIR}/Image kernel.img
    ../tools/mkimg --dtb ${ROCKCHIP_KERNEL_DTB_NAME}
    sed -e "s:path_to_kernel:${WORKDIR}\/build:g" -e "s:dtb_name:${ROCKCHIP_KERNEL_DTB_NAME}:g" \
        ${WORKDIR}/tools/its_config > .tmp_its_config
    ../tools/mkimage -f .tmp_its_config -E -p 0x800 boot.img
    rm -rf .tmp_its_config
}

do_compile:append:rk3399(){
    cp ../logo/* ./
    scripts/mkkrnlimg ${KERNEL_OUTPUT_DIR}/Image kernel.img
    ../tools/mkimg --dtb ${ROCKCHIP_KERNEL_DTB_NAME}
    ../tools/mkbootimg --kernel ${KERNEL_OUTPUT_DIR}/Image --second resource.img -o boot.img
}

do_deploy:append(){
    install ${B}/boot.img "${DEPLOYDIR}/boot.img"
}

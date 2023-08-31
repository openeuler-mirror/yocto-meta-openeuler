# add recipes-kernel path to find patch and defconfig
FILESEXTRAPATHS:append := "${THISDIR}/files/:"
# add patch prebuild tools and logo
SRC_URI:append = " \
    file://config/ \
    file://patches/0000-rk3568-kernel.patch.gz;name=rk3568-kernel-patch \
    file://tools \
    file://logo \
"

# patches for ryd-3568
SRC_URI:append:ryd-3568 = " \
    file://patches/0001-rk3568-8897-dts.patch \
    file://patches/0002-ryd-gpio-control.patch \
    "
# mcs patch for ok3568 devicetree
SRC_URI:append = " \
    ${@bb.utils.contains('MCS_FEATURES', 'openamp', 'file://patches/0003-ok3568-support-mcs.patch', '', d)} \
"

# more support of device is comming. so we documented this patch md5sum.
SRC_URI[rk3568-kernel-patch.md5sum] = "7643792b2483b3156dbc349d6fd41ef9"

# add patch tool to solve patch apply
PATCHTOOL = "git"

OPENEULER_KERNEL_CONFIG = "file://config/${MACHINE}/defconfig"

# add method to do_compile task to produce bootable Image
do_compile:append:rk3568(){
    cp ../logo/* ./
    scripts/mkkrnlimg ${KERNEL_OUTPUT_DIR}/Image kernel.img
    ../tools/mkimg --dtb ${RK3568_KERNEL_DTB_NAME}
    sed -e "s:path_to_kernel:${WORKDIR}\/build:g" -e "s:dtb_name:${RK3568_KERNEL_DTB_NAME}:g" \
        ${WORKDIR}/tools/its_config > .tmp_its_config
    ../tools/mkimage -f .tmp_its_config -E -p 0x800 boot.img
    rm -rf .tmp_its_config
}

# add boot.img to $D
do_install:append(){
    cp ${B}/boot.img ${D}/boot
}
PACKAGES += "bootfile"
FILES:bootfile="/boot/boot.img"
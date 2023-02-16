# add recipes-kernel path to find patch and defconfig
FILESEXTRAPATHS_append := "${THISDIR}/files/:"
# add patch prebuild tools and logo
SRC_URI_append = " \
    file://config/OK3568-C-linux_defconfig \
    file://patches/0000-ok3568-kernel.patch.gz;name=ok3568-kernel-patch \
    file://tools \
    file://logo \
"

# more support of device is comming. so we documented this patch md5sum.
SRC_URI[ok3568-kernel-patch.md5sum] = "f6599687190dbf8381a0029980973b46"

# add patch tool to solve patch apply
PATCHTOOL = "git"

OPENEULER_KERNEL_CONFIG = "../config/OK3568-C-linux_defconfig"

# add method to do_compile task to produce bootable Image
do_compile_append_ok3568(){
    cp ../logo/* ./
    scripts/mkkrnlimg ${KERNEL_OUTPUT_DIR}/Image kernel.img
    ../tools/mkimg --dtb OK3568-C-linux.dtb
    sed "s:path_to_kernel:${WORKDIR}\/build:g" ../tools/its_config >.tmp_its_config
    ../tools/mkimage -f .tmp_its_config   -E -p 0x800 boot.img
    rm -rf .tmp_its_config
}

# add boot.img to $D
do_install_append(){
    cp ${B}/boot.img ${D}/boot
}
PACKAGES += "bootfile"
FILES_bootfile="/boot/boot.img"
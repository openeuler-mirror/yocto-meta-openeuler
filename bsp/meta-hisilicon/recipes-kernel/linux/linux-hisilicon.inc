# add recipes-kernel path to find patch and defconfig
FILESEXTRAPATHS:append := "${THISDIR}/files/:"
# add prebuild tools to make uImage
SRC_URI:append = " \
    file://dtbs \
    file://tools \
"

# add patch tool to solve patch apply
PATCHTOOL = "git"

# add method to do_compile task to produce bootable Image
do_compile:append:hi1711(){
    ../tools/mkimage -A arm -O linux -T kernel -C none -a 0x98280000 -e 0x98280040 -n linux-5.10.0 -d ${KERNEL_OUTPUT_DIR}/zImage uImage
}

# add uImage to $D
do_install:append(){
    cp uImage ${D}/boot
    cp ../dtbs/hi3093*.dtb ${D}/boot
}
PACKAGES += "bootfile"
FILES:bootfile="/boot/uImage \
${@bb.utils.contains('MCS_FEATURES', 'openamp', '/boot/hi3093-mcs.dtb', '/boot/hi3093.dtb', d)} \
"

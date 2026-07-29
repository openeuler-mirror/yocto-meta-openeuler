OPENEULER_REPO_NAMES = "kernel-5.10-tag3095 src-kernel-5.10-tag3095"

# add recipes-kernel path to find patch and defconfig
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

PV = "5.10-tag3095"
OPENEULER_KERNEL_CONFIG = "file://config/hi3095/defconfig"

# add device tree
KERNEL_DIR_NAME = "${@d.getVar('OPENEULER_REPO_NAMES').split()[0]}"
SRC_URI:append = " \
    file://dtbs/hi3095.dts \
"

do_configure:append:hi3095() {
    SRC_DTS="${WORKDIR}/dtbs/hi3095.dts"
    DST_DTS="${S}/arch/arm64/boot/dts/hisilicon/hi3095.dts"
    
    if [ -f "${SRC_DTS}" ]; then
        cp -f "${SRC_DTS}" "${DST_DTS}"
        bbnote "Copied hi3095.dts to ${DST_DTS}"
        
        DTS_DIR="${S}/arch/arm64/boot/dts/hisilicon"
        if ! grep -q "hi3095.dtb" "${DTS_DIR}/Makefile"; then
            sed -i '1i dtb-y += hi3095.dtb' "${DTS_DIR}/Makefile"
            bbnote "Added hi3095.dtb to Makefile"
        fi
    else
        bbfatal "hi3095.dts not found at ${SRC_DTS}"
    fi
}

DEPENDS:append = " u-boot-mkimage-native"

do_compile:prepend:hi3095() {
    rm -f "${DEPLOY_DIR_IMAGE}/uImage"
}

do_compile:append:hi3095() {
    if [ ! -f "${B}/arch/arm64/boot/zImage" ]; then
        bbfatal "zImage not found, cannot generate uImage"
    fi

    UBOOT_LOADADDRESS=${UBOOT_LOADADDRESS}
    UBOOT_ENTRYPOINT=${UBOOT_ENTRYPOINT}

    LOADADDR="${UBOOT_LOADADDRESS:-0x80008000}"
    ENTRYPOINT="${UBOOT_ENTRYPOINT:-${LOADADDR}}"

    MKIMAGE="${STAGING_BINDIR_NATIVE}/mkimage"
    if [ ! -x "${MKIMAGE}" ]; then
        bbfatal "mkimage not found at ${MKIMAGE}. Please ensure u-boot-mkimage-native is built."
    fi
    
    ${MKIMAGE} -A arm64 -O linux -C none -T kernel -a ${LOADADDR} -e ${ENTRYPOINT} -n "Linux kernel" -d ${B}/arch/arm64/boot/zImage ${B}/arch/arm64/boot/uImage
    if [ -f "${B}/arch/arm64/boot/uImage" ]; then
        bbnote "Successfully created uImage"
    else
        bbfatal "Failed to create uImage"
    fi
}
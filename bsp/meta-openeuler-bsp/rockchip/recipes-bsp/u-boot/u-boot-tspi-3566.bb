require recipes-bsp/u-boot/rockchip-common.inc

PARAMETER = "tspi-3566-parameter"

SRC_URI:append = " \
    file://${PARAMETER} \
"

do_copy_rkbin_source() {
	mv rk-binary-native rkbin
}

do_configure:prepend() {
	# the python scripts need python2, so we create tmp soft link
    ln -sf $(which python) ${RECIPE_SYSROOT_NATIVE}${bindir_native}/python2
}

do_compile() {
	cd ${S}
	./make.sh CROSS_COMPILE=aarch64-openeuler-linux- rk3566
}

do_install() {
}

do_deploy() {
	cd ${S}
    test -d "${OUTPUT_DIR}" || mkdir -p "${OUTPUT_DIR}"
    if [ -f "uboot.img" ]; then
        install uboot.img ${OUTPUT_DIR}
    fi
    if ls *_loader*.bin 1> /dev/null 2>&1; then
        install *_loader*.bin ${OUTPUT_DIR}/MiniLoaderAll.bin
    fi
}

# add parameter to deploy directory
do_deploy:append() {
    if [ -f "${WORKDIR}/${PARAMETER}" ]; then
        install ${WORKDIR}/${PARAMETER} ${OUTPUT_DIR}/parameter.txt
    fi
}

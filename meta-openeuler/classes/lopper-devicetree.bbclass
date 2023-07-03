DEPENDS += "lopper-ops lopper-native"

LOPS_DIR = "${WORKDIR}/recipe-sysroot/${libdir}/lops"

# ${INPUT_DT} - input device tree(dts or dtb)
# ${OUTPUT_DT} - modified device tree(dts or dtb), normally a dtb for Linux
# Note: These two variables require absolute path
INPUT_DT = ""
OUTPUT_DT = ""

# Output the device-trees (determined in lopper operation) to OUT_DIR
# These device-trees will be installed to SYSROOT_DIRS/INSTALL_PATH
OUT_DIR = "${B}/lop_dts"
INSTALL_PATH = "/lop_dts"

apply_lopper_ops() {
    local args=""

    if [ ! -d "${LOPS_DIR}" ]; then
        bbfatal_log "lopper-devicetree: No valid lopper-ops was found. No such directory: ${LOPS_DIR}"
    fi

    for lops in "${LOPS_DIR}"/*; do
        bbnote "lopper: apply ${lops}"
        args+=" -i ${lops}"
    done
    echo ${args}
}

# Takes an input device tree, applies lopper operations to that tree,
# and outputs one or more modified/processed trees to OUT_DIR.
do_mkdts() {
    if [ ! -f "${INPUT_DT}" ]; then
        bbfatal_log "lopper-devicetree: No such input file: ${INPUT_DT}"
    fi

    local include_lops=$(apply_lopper_ops)

    mkdir -p ${OUT_DIR}

    lopper -v --werror --enhanced \
        ${include_lops} \
        -f -O ${OUT_DIR} \
        -o ${OUTPUT_DT} ${INPUT_DT}
}
addtask mkdts before do_install after do_compile

SYSROOT_DIRS += "${INSTALL_PATH}"
FILES:${PN} = "${INSTALL_PATH}/*.dts"

# install the processed device tree to SYSROOT_DIRS
# other recipes can get it in "${WORKDIR}/recipe-sysroot/lop_dts"
do_install_lop_dts() {
    install -d ${D}${INSTALL_PATH}

    for dt in "${OUT_DIR}"/*.dts; do
        bbnote "lopper: install ${dt}"
        install ${dt} ${D}${INSTALL_PATH}/
    done
}
do_install_lop_dts[dirs] = "${OUT_DIR}"
addtask install_lop_dts after do_install before do_package do_populate_sysroot

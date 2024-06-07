# this bbclass like image_types_wic.bbclass
# it's used to automatic pack the image which can put spl at "0" offset

GENIMAGE_CONFIG_FILE ??= "${MACHINE}.config"
GENIMAGE_CONFIG_FILE_NAME = "${@d.getVar('GENIMAGE_CONFIG_FILE').split('.')[0]}"
GENIMAGE_SEARCH_PATH ?= "${THISDIR}:${@':'.join('%s/genimage' % p for p in '${BBPATH}'.split(':'))}"
GENIMAGE_CONFIG_FILE_PATH = "${@genimage_search(d.getVar('GENIMAGE_CONFIG_FILE'), d.getVar('GENIMAGE_SEARCH_PATH')) or ''}"

def genimage_search(file, search_path):
    if os.path.isabs(file):
        if os.path.exists(file):
            return file
    else:
        paths = search_path.split(':')
        for path in paths:
            searched = bb.utils.which(path, file)
            if searched:
                return searched
    return ''

GENIMAGE_BUILD_PATH = "${WORKDIR}/build-genimage"

IMAGE_CMD:genimage () {
    out="${IMGDEPLOYDIR}/${IMAGE_NAME}"
    tmp_genimage="${WORKDIR}/tmp-genimage"

    if [ -e "$tmp_genimage" ]; then
        # Ensure we don't have any junk leftover from a previously interrupted
        # do_image_genimage execution
        rm -rf $tmp_genimage
    fi

    tmp_genimage_config=${GENIMAGE_BUILD_PATH}/tmp_genimage.config
    cp -f ${GENIMAGE_CONFIG_FILE_PATH} $tmp_genimage_config

    # replace @GENIMAGE_OUTPUT_NAME@ in genimage config
    tmp_genimage_output_name=${IMAGE_NAME}.genimage
    sed -i "s:@GENIMAGE_OUTPUT_NAME@:$tmp_genimage_output_name:g" $tmp_genimage_config

    genimage \
        --loglevel 2 \
        --config $tmp_genimage_config \
        --tmppath $tmp_genimage \
        --inputpath ${DEPLOY_DIR_IMAGE} \
        --includepath ${WORKDIR} \
        --outputpath ${GENIMAGE_BUILD_PATH} \
        --rootpath ${WORKDIR}/rootfs 

    mv ${GENIMAGE_BUILD_PATH}/$tmp_genimage_output_name $out${IMAGE_NAME_SUFFIX}.genimage
}

do_image_genimage[cleandirs] = "${GENIMAGE_BUILD_PATH}"

do_image_genimage[depends] += "${@' '.join('%s-native:do_populate_sysroot' % r for r in ('genimage', 'genext2fs', 'e2fsprogs'))}"

# mcs-oci-utils.bbclass serves for OCI-compatibility artifacts setup for MICA
# 1. filter required sample files
# 2. package sample files into output directory
# 3. add more logics about oci containerizations
# 4. update qemu boot configurations
python __anonymous () {
    bb.note("mcs-oci-utils.bbclass: inherited")
}

# enlarge dom0_mem for containerization + systemd + oci tools
QB_XEN_CMDLINE_EXTRA = "dom0_mem=1536M"
HAS_MICRUN = "${@bb.utils.contains('MCS_FEATURES', 'micrun', '1', '0', d)}"
HAS_ZEPHYR = "${@bb.utils.contains('MCS_FEATURES', 'zephyr', '1', '0', d)}"
HAS_UNIPROTON = "${@bb.utils.contains('MCS_FEATURES', 'uniproton', '1', '0', d)}"
HAS_XEN = "${@bb.utils.contains('MCS_FEATURES', 'xen', '1', '0', d)}"

debug_mcs_features () {
  bbnote "HAS_ZEPHYR = $HAS_ZEPHYR"
  bbnote "HAS_UNIPROTON = $HAS_UNIPROTON"
  bbnote "HAS_XEN = $HAS_XEN"
}

micrun_script_src="${DEPLOY_DIR_IMAGE}/micrun-scripts"
micrun_output_dir="${OUTPUT_DIR}/micrun-files"

# Copy Some artifacts that Micrun qemu sample requires to the OUTPUT directory
# Currently, this class works only for mcs/xen + micrun
copy_binary_artifacts() {

    if [ "${HAS_MICRUN}" != "1" ]; then
      return 0
    fi

    bbnote "Copying mcs/Xen specific artifacts to OUTPUT directory"
    test -d "${micrun_output_dir}" || mkdir -p "${micrun_output_dir}"

    if [ "${HAS_ZEPHYR}" = "1" ]; then
        bbnote "Copying Zephyr images (zephyr feature enabled)"
        for zf in ${DEPLOY_DIR_IMAGE}/zephyr.*; do
            if [ -f "$zf" ]; then
                cp -fp "$zf" ${micrun_output_dir}/
            fi
        done
        # If mcs/xen is enabled, sample files requires *.bin
        [ "${HAS_XEN}" = 1 ] && cp -fp "zephyr.bin" ${micrun_output_dir}/
    fi

    if [ "${HAS_UNIPROTON}" = "1" ]; then
        bbnote "Copying Uniproton images (uniproton feature enabled)"
        for uniproton_file in ${DEPLOY_DIR_IMAGE}/uniproton.*; do
            if [ -f "$uniproton_file" ]; then
                cp -fp "$uniproton_file" ${micrun_output_dir}/
            fi
        done

        # If mcs/xen is enabled, sample files requires *.bin
        [ "${HAS_XEN}" = 1 ] && cp -fp "uniproton.bin" ${micrun_output_dir}/
    fi
}

# Copy micrun scripts to OUTPUT directory without installing to rootfs
copy_micrun_scripts() {
    if [ "${HAS_MICRUN}" != "1" ]; then
        return 0
    fi

    test -d "${micrun_output_dir}" || mkdir -p "${micrun_output_dir}"


    if [ -d "${micrun_script_src}" ]; then
        mkdir -p "${micrun_output_dir}"
        cp -rfp ${micrun_script_src}/* "${micrun_output_dir}"/
        bbnote "Micrun scripts copied to ${micrun_output_dir}"
    else
        bbwarn "No micrun scripts found in ${micrun_script_src}"
    fi
}

IMAGE_POSTPROCESS_COMMAND:append = "debug_mcs_features;"
IMAGE_POSTPROCESS_COMMAND:append = "copy_binary_artifacts;"
IMAGE_POSTPROCESS_COMMAND:append = "copy_micrun_scripts;"

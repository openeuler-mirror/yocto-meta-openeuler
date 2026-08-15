# Enable booting mcs feature with qemuboot / runqemu: generate device tree
#
# Copyright (c) 2023 openEuler Embedded. All rights reserved.
#

# Interface variables:
#
# QB_DTB : defined in qemuboot.bbclass.
# If set, this class will generate the specified device tree file.
#
# See also: Other QB_ variables as defined by the qemuboot.bbclass.

# QB_SYSTEM_NAME requires qemu-system-native
DEPENDS += "qemu-system-native"

# When lopper-devicetree is in MCS_FEATURES, pull in lopper tools and
# user lop files so that peripheral partition operations are applied
# to the QEMU-generated device tree.
DEPENDS += "${@bb.utils.contains('MCS_FEATURES', 'lopper-devicetree', 'lopper-ops lopper-native', '', d)}"

# Directory where user lopper operation files (.dts) are installed by
# the lopper-ops recipe (populated via recipe-sysroot).
LOPS_DIR = "${WORKDIR}/recipe-sysroot/${libdir}/lops"

# Output directory for extracted guest-side device trees.
LOP_DTS_OUT_DIR = "${B}/lop_dts"

# Whether lopper-devicetree is enabled (expanded at parse time).
LOPPER_ENABLED = "${@bb.utils.contains('MCS_FEATURES', 'lopper-devicetree', '1', '0', d)}"

write_mcs_section() {
    # remove last '}'
    sed -i '$ d' $1
	cat <<-END >> $1

	        reserved-memory {
	            #address-cells = <0x02>;
	            #size-cells = <0x02>;
	            ranges;
	
	            ivshmem_pci@6fffc000 {
	                reg = <0x00 0x6fffc000 0x00 0x4000>;
	                no-map;
	            };
	
	            client_os_reserved: client_os_reserved@7a000000 {
	                reg = <0x00 0x7a000000 0x00 0x4000000>;
	                no-map;
	            };
	
	            client_os_dma_memory_region: client_os-dma-memory@70000000 {
	                compatible = "shared-dma-pool";
	                reg = <0x00 0x70000000 0x00 0x100000>;
	                no-map;
	            };
	        };
	
	        mcs-remoteproc {
	            compatible = "oe,mcs_remoteproc";
	            memory-region = <&client_os_dma_memory_region>,
	                            <&client_os_reserved>;
	        };
	    };
	END
}

# Collect -i arguments for all lopper operation files in LOPS_DIR.
# Mirrors the logic in lopper-devicetree.bbclass so that the same
# user .dts configs (lop-extract-rtc-for-guest.dts, etc.) are applied.
apply_lopper_ops() {
    local args=""

    if [ ! -d "${LOPS_DIR}" ]; then
        bbfatal_log "qemuboot-mcs-dtb: lopper-devicetree enabled but no lopper-ops found. No such directory: ${LOPS_DIR}"
    fi

    for lops in "${LOPS_DIR}"/*; do
        bbnote "lopper: apply ${lops}"
        args+=" -i ${lops}"
    done
    echo ${args}
}

generate_mcs_qemuboot_dtb() {
    TMP_DTS="tmp.qemu.dts"
    # First: invoke qemu to generate an initial device tree.
    # Parameters supplied here inspired by inspection of:
    #   runqemu "${IMAGE_BASENAME}" nographic slirp \
    #            qemuparams='-dtb "" -machine dumpdtb=${B}/qemu-dumped.dtb'
    ${QB_SYSTEM_NAME} \
        ${QB_MACHINE} \
        ${QB_CPU} \
        ${QB_SMP} \
        ${QB_MEM} \
        -nographic \
        -serial mon:stdio \
        -machine "dumpdtb=${B}/qemu-dumped.dtb" 2>/dev/null

    cd "${B}"

    dtc -I dtb -O dts -o ${B}/${TMP_DTS} ${B}/qemu-dumped.dtb

    write_mcs_section "${B}/${TMP_DTS}"

    QEMUBOOT_DTB="${IMGDEPLOYDIR}/${QB_DTB}"
    QEMUBOOT_DTB_LINK="${IMGDEPLOYDIR}/${QB_DTB_LINK}"

    dtc -I dts -O dtb -o ${QEMUBOOT_DTB} ${B}/${TMP_DTS}

    # When lopper-devicetree is enabled, apply user lopper operations to
    # the generated device tree.  This extracts devices (e.g. RTC) for
    # the guest OS and removes them from the Linux device tree.
    if [ "${LOPPER_ENABLED}" = "1" ]; then
        local include_lops=$(apply_lopper_ops)
        mkdir -p ${LOP_DTS_OUT_DIR}

        bbnote "lopper: applying peripheral partition operations to ${QEMUBOOT_DTB}"
        # Use a temp file as lopper output to avoid reading and writing
        # the same file simultaneously.
        local LOPPER_OUTPUT="${B}/qemu-lopper-output.dtb"

        lopper -v --werror --enhanced \
            ${include_lops} \
            -f -O ${LOP_DTS_OUT_DIR} \
            -o ${LOPPER_OUTPUT} \
            ${QEMUBOOT_DTB}

        # Replace the original dtb with the lopper-processed version
        cp ${LOPPER_OUTPUT} ${QEMUBOOT_DTB}

        # Deploy extracted guest device trees alongside the qemuboot dtb
        if ls ${LOP_DTS_OUT_DIR}/*.dts 1>/dev/null 2>&1; then
            for dt in ${LOP_DTS_OUT_DIR}/*.dts; do
                bbnote "lopper: deploying guest dts ${dt}"
                cp ${dt} ${IMGDEPLOYDIR}/
            done
        fi
    fi

    if [ "${QEMUBOOT_DTB_LINK}" != "${QEMUBOOT_DTB}" ] ; then
        if [ -e "${QEMUBOOT_DTB_LINK}" ] ; then
            rm "${QEMUBOOT_DTB_LINK}"
        fi
        ln -s "${QB_DTB}" "${QEMUBOOT_DTB_LINK}"
    fi
}

do_write_mcs_qemuboot_dtb() {
    # We may not need to do this for some machines.
    # For example, generic-x86 doesn't need it.
    bbdebug 2 "ignore do_write_mcs_qemuboot_dtb"
}

do_write_mcs_qemuboot_dtb:qemu-aarch64() {
    # Not all architectures qemuboot with a device tree binary, so check
    # to see if one is needed. This allows this bbclass file to be used
    # in the same image recipe for multiple architectures.
    if [ -n "${QB_DTB}" ] && [ -n "${QB_SYSTEM_NAME}" ] ; then
        generate_mcs_qemuboot_dtb
    fi
}

addtask do_write_mcs_qemuboot_dtb after do_write_qemuboot_conf before do_image

# Task-level dependencies ensure native tools are built and their sysroots
# are populated BEFORE do_write_mcs_qemuboot_dtb runs.
# - qemu-system-native: provides qemu-system-aarch64 for dumpdtb
# - dtc-native: provides dtc for dtb↔dts conversion
# - lopper-native: provides lopper binary (conditional on lopper-devicetree)
# - lopper-ops: provides user lop .dts files in recipe-sysroot (conditional)
do_write_mcs_qemuboot_dtb[depends] += "qemu-system-native:do_populate_sysroot"
do_write_mcs_qemuboot_dtb[depends] += "${@bb.utils.contains('MCS_FEATURES', 'lopper-devicetree', 'lopper-native:do_populate_sysroot lopper-ops:do_populate_sysroot dtc-native:do_populate_sysroot', 'dtc-native:do_populate_sysroot', d)}"

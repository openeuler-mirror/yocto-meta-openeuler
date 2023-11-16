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

    if [ "${QEMUBOOT_DTB_LINK}" != "${QEMUBOOT_DTB}" ] ; then
        if [ -e "${QEMUBOOT_DTB_LINK}" ] ; then
            rm "${QEMUBOOT_DTB_LINK}"
        fi
        ln -s "${QB_DTB}" "${QEMUBOOT_DTB_LINK}"
    fi
}

do_write_mcs_qemuboot_dtb() {
    # Not all architectures qemuboot with a device tree binary, so check
    # to see if one is needed. This allows this bbclass file to be used
    # in the same image recipe for multiple architectures.
    if [ -n "${QB_DTB}" ] && [ -n "${QB_SYSTEM_NAME}" ] ; then
        generate_mcs_qemuboot_dtb
    fi
}

addtask do_write_mcs_qemuboot_dtb after do_write_qemuboot_conf before do_image

# add recipes-kernel path to find patch and defconfig
FILESEXTRAPATHS:append := "${THISDIR}/files/:"

# for mkimage
DEPENDS += "u-boot-tools-native dtc-native"

# add prebuild tools to make uImage
SRC_URI = " \
    file://kernel-5.10-tag3093 \
    file://tools \
    file://config/hi3093/defconfig \
    file://mpu_solution/src/non_real_time/adapter_for_hi3093/include/kbox \
    file://mpu_solution/platform/securec/include \
    file://mpu_solution/src/patches/openEuler \
    file://dtbs/hi3093_mcs_3with1.dts \
    file://dtbs/hi3093_mcs_2with2.dts \
    file://dtbs/hi3093.dts \
"

# add patch tool to solve patch apply
PATCHTOOL = "git"

# add method to do_compile task to produce bootable Image
do_compile:append(){
    mkimage -A arm -O linux -T kernel -C none -a 0x98280000 -e 0x98280040 -n linux-5.10.0 -d ${KERNEL_OUTPUT_DIR}/zImage uImage
    dtc -I dts -O dtb -o hi3093_mcs_3with1.dtb ${WORKDIR}/dtbs/hi3093_mcs_3with1.dts
    dtc -I dts -O dtb -o hi3093_mcs_2with2.dtb ${WORKDIR}/dtbs/hi3093_mcs_2with2.dts
    dtc -I dts -O dtb -o hi3093.dtb ${WORKDIR}/dtbs/hi3093.dts
}

WORKDTB = "${@bb.utils.contains('MCS_FEATURES', 'openamp', 'hi3093_mcs_3with1.dtb', 'hi3093.dtb', d)}"

# add uImage to $D
do_install:append(){
    cp uImage ${D}/boot
    cp -f ${WORKDTB} ${D}/boot/hi1711_asic.dtb
}

PACKAGES += "bootfile"
FILES:bootfile=" \
    /boot/uImage \
    /boot/hi1711_asic.dtb \
"
RPROVIDES:${PN} += "bootfile"

python do_fetch() {
    # download src-openeuler/kernel repo for patches
    d.setVar("OPENEULER_REPO_NAME", "kernel")
    d.setVar("OPENEULER_LOCAL_NAME", 'src-kernel-5.10-tag3093')
    bb.build.exec_func("do_openeuler_fetch", d)

    # download openeuler/kernel-5.10 repo for linux kernel src files
    d.setVar("OPENEULER_REPO_NAME", "kernel-5.10")
    d.setVar("OPENEULER_LOCAL_NAME", 'kernel-5.10-tag3093')
    bb.build.exec_func("do_openeuler_fetch", d)
}

S = "${WORKDIR}/kernel-5.10-tag3093"

do_copy_headers() {
    cd ${S}/
    # Due to the large number of patch hunks, 
    # yocto's built-in patch mechanism has abnormal failure issues. 
    # Here is a solution to avoid this issue
    grep  "Missing single sector read for large sector size" ${S}/drivers/mmc/core/block.c || patch -p1 < ${WORKDIR}/mpu_solution/src/patches/openEuler/kernel-22.03-lts-sp1-mmc.patch
    cd -
    cp -rf ${WORKDIR}/mpu_solution/platform/securec/include/* ${S}/include/linux
    mkdir -p ${S}/include/linux/kbox
    cp -rf ${WORKDIR}/mpu_solution/src/non_real_time/adapter_for_hi3093/include/kbox/* ${S}/include/linux/kbox
}
addtask do_copy_headers after do_patch before do_configure

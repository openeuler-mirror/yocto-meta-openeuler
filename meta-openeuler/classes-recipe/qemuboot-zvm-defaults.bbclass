# Usually, the runqemu startup method uses Linux openeuler as the kernel,
# and depends on the corresponding rootfs file and dtb.
# However, under the zvm-host feature, runqemu startup uses zvm-host as the kernel,
# with openeuler running on zvm. 
# Some qemu boot configurations need to be changed. 
# During startup, the image rootfs and dtb will be directly loaded to the specified memory addresses.

# zvm start linux-openeuler by Image 
KERNEL_IMAGETYPE = "Image"
ZVM_VLINUX_IMAGE_NAME = "zvm-openeuler"


QB_DEFAULT_KERNEL = "zvm_host.elf"

QB_CPU = "-cpu max"
QB_SMP = "-smp 4"
QB_MEM = "-m 4096" 
QB_KERNEL_CMDLINE_APPEND = "maxcpus=4"
QB_MACHINE= "-machine virt,gic-version=3 -machine virtualization=true"

QB_OPT_APPEND:append:qemu-aarch64= " \
    -chardev stdio,id=con,mux=on \
    -mon chardev=con,mode=readline \
    -serial chardev:con \
    -serial pty \
    -serial pty \
    "
ZEPHYR_ADDR         = "0xc8000000"
LINUX_ADDR          = "0xe0000000"
LINUX_ROOTFS_ADDR   = "0xe4000000"
VLINUX_DTB_ADDR     = "0xf2a00000"
VLINUX_DTB          = "zvm-openeuler.dtb"
ZVM_VLINUX_IMAGE_NAME = "zvm-openeuler"

QB_OPT_APPEND:append:qemu-aarch64= " \
    -nographic -net none -pidfile qemu.pid \
    -device loader,file=${DEPLOY_DIR_IMAGE}/zephyr.bin,addr=${ZEPHYR_ADDR},force-raw=on \
    -device loader,file=${DEPLOY_DIR_IMAGE}/${ZVM_VLINUX_IMAGE_NAME}-${KERNEL_IMAGETYPE},addr=${LINUX_ADDR},force-raw=on \
    -device loader,file=${DEPLOY_DIR_IMAGE}/${ZVM_VLINUX_IMAGE_NAME}.cpio.gz,addr=${LINUX_ROOTFS_ADDR},force-raw=on \
    -device loader,file=${DEPLOY_DIR_IMAGE}/${VLINUX_DTB},addr=${VLINUX_DTB_ADDR} \
    "

RDEPENDS:append = " \
    zvm \
    zvm-openeuler-dtb \
    "

# make install or nologin when using busybox-inittab
set_permissions_from_rootfs:append() {
    cd "${IMAGE_ROOTFS}"
    if [ -e ./etc/inittab ];then
        sed -i "s#respawn:/sbin/getty.*#respawn:-/bin/sh#g" ./etc/inittab
    fi
    cd -
}
# modify the atsk:copy_openeuler_distro 
IMAGE_POSTPROCESS_COMMAND:remove = "copy_openeuler_distro;"
copy_openeuler_distro() {
    set -x
    test -d "${OUTPUT_DIR}" || mkdir -p "${OUTPUT_DIR}"
    
    # Copy rootfs image to OUTPUT
    for IMAGETYPE in ${IMAGE_FSTYPES}
    do
        if [ -f ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX%.rootfs}.*${IMAGETYPE} ];then
            rm -f "${OUTPUT_DIR}"/${IMAGE_NAME}${IMAGE_NAME_SUFFIX%.rootfs}.*${IMAGETYPE}
            cp -fp ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX%.rootfs}.*${IMAGETYPE} "${OUTPUT_DIR}"/
            cp -fp ${IMGDEPLOYDIR}/${IMAGE_NAME}${IMAGE_NAME_SUFFIX}.${IMAGETYPE} "${IMGDEPLOYDIR}"/${ZVM_VLINUX_IMAGE_NAME}.${IMAGETYPE}
        fi
    done

    # Copy kernel image to OUTPUT with new naming format
    for kernel_img in zImage bzImage uImage Image zboot.img boot.img vmlinux; do
        if [ -f "${DEPLOY_DIR_IMAGE}/${kernel_img}" ]; then
            cp -fp "${DEPLOY_DIR_IMAGE}/${kernel_img}" "${OUTPUT_DIR}/zvm-openeuler-${kernel_img}"
            cp -fp "${DEPLOY_DIR_IMAGE}/${kernel_img}" "${DEPLOY_DIR_IMAGE}/zvm-openeuler-${kernel_img}"
        fi
    done
    set +x
}

IMAGE_POSTPROCESS_COMMAND:append = "copy_openeuler_distro;"

# Remove QEMU opt
QB_DTB = ""
QB_DTB_LINK = ""
QB_CMDLINE_IP_SLIRP = ""
QB_CMDLINE_IP_TAP = ""
QB_GRAPHICS = ""
QB_NETWORK_DEVICE = ""
QB_RNG = ""
QB_ROOTFS_EXTRA_OPT = ""
QB_TAP_OPT = ""
QB_TCPSERIAL_OPT = ""
QB_ROOTFS_OPT = ""
QB_SERIAL_OPT = ""

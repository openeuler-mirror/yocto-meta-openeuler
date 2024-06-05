GRUB_SERIAL := ""
GRUB_TIMEOUT := "0"
GRUB_OPTS := ""
# add rw to fix https://gitee.com/openeuler/yocto-meta-openeuler/issues/I5ZES2
APPEND = "coherent_pool=1M 8250.nr_uarts=1 snd_bcm2835.enable_compat_alsa=0 snd_bcm2835.enable_hdmi=1 bcm2708_fb.fbwidth=1920 bcm2708_fb.fbheight=1080 bcm2708_fb.fbswap=1 vc_mem.mem_base=0x3ec00000 vc_mem.mem_size=0x40000000  dwc_otg.lpm_enable=0 rw console=tty1 console=ttyS0,115200 console=ttyAMA0,115200"
# do init_resize.sh to expand file system to use all the space on the card at first boot
APPEND += "${@oe.utils.conditional("AUTO-EXPAND-FS", "1", "init=/usr/lib/init_resize.sh", "", d)}"
GRUB_ROOT := "root=/dev/mmcblk0p2 rootfstype=ext4 rootwait"

#set maxcpus=3, reserve cpu3 for clientos
APPEND += "${@bb.utils.contains("MCS_FEATURES", "openamp", "maxcpus=3", "", d)}"

# To boot an image with guest os, we use the initramfs image as the Monitor VM.
require ${@bb.utils.contains('BUILD_GUEST_OS', '1', 'initrd.inc', '', d)}

inherit deploy

do_deploy() {
    install -d ${DEPLOYDIR}/EFI/BOOT
    GRUBCFG=${DEPLOYDIR}/EFI/BOOT/grub.cfg
    cp ${S}/grub-bootconf $GRUBCFG

    # change grub.cfg to use Image.gz to launch the kernel if enable mcs DISTRO_FEATURES
    if ${@bb.utils.contains('DISTRO_FEATURES', 'mcs', 'true', 'false', d)}; then
        sed -i 's/linux \/Image /linux \/Image.gz /' $GRUBCFG
    fi
}

addtask deploy after do_install before do_build
do_deploy[dirs] += "${DEPLOYDIR}/EFI/BOOT"

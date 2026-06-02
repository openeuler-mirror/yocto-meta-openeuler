GRUB_SERIAL := ""
GRUB_TIMEOUT := "0"
GRUB_OPTS := ""
# add rw to fix https://gitee.com/openeuler/yocto-meta-openeuler/issues/I5ZES2
APPEND = "rw"
GRUB_ROOT := "root=PARTUUID="0a52c129-7e0f-43ad-989f-d96b07ccdbb2" rootfstype=ext4 rootdelay=10"

inherit deploy

do_deploy() {
    install -d ${DEPLOYDIR}/EFI/BOOT
    GRUBCFG=${DEPLOYDIR}/EFI/BOOT/grub.cfg
    cp ${S}/grub-bootconf $GRUBCFG
}

addtask deploy after do_install before do_build
do_deploy[dirs] += "${DEPLOYDIR}/EFI/BOOT"

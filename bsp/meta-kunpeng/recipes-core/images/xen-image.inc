# install xen.cfg via grub-efi.bbclass
python build_efi_cfg:append() {
    XEN_GRUB_CFG = """
    menuentry 'xen'{
            xen_hypervisor /xen-kp920 dom0_mem=1024M
            xen_module /Image earlyprintk earlycon=pl011,0x94080000 root=/dev/sda2 console=ttyAMA0,115200n8 rw rootwait
    }
    """

    try:
        cfgfile = open(cfile, 'a')
    except OSError:
        bb.fatal('Unable to open %s' % cfile)

    cfgfile.write(XEN_GRUB_CFG)
    cfgfile.close()
}

# install xen
populate_live:append() {
        if [ -e ${DEPLOY_DIR_IMAGE}/xen-${MACHINE} ]; then
            install -m 0644 ${DEPLOY_DIR_IMAGE}/xen-${MACHINE} $1/
       fi
}

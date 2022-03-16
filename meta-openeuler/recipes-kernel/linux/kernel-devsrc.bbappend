RDEPENDS_${PN} = ""
RDEPENDS_${PN}_remove_aarch64 = " gawk"

do_install_append() {
    # copy the entie source tree. copy source from build dir and then copy source dir
    # copy in parts from the build that we'll need later
    (
        cd ${B}
        find . -depth -not -name "*.cmd" -not -name "*.o" -not -path "./.*" -print0 | cpio --null -pdu  $kerneldir/build/
        cp .config $kerneldir/build/
        cp -a --parents arch/${ARCH}/include/generated/uapi/asm/ $kerneldir/build/
        # delete host tools caused do_package task error
        rm -f $kerneldir/build/scripts/selinux/genheaders/genheaders
        rm -f $kerneldir/build/scripts/selinux/mdp/mdp
        rm -f $kerneldir/build/scripts/dtc/dtc
        rm -f $kerneldir/build/scripts/extract-cert
        rm -f $kerneldir/build/scripts/kallsyms
        rm -f $kerneldir/build/scripts/mod/mk_elfconfig
        rm -f $kerneldir/build/scripts/sorttable
        rm -f $kerneldir/build/scripts/kconfig/conf
        rm -f $kerneldir/build/scripts/mod/modpost
        rm -f $kerneldir/build/scripts/genksyms/genksyms
        rm -f $kerneldir/build/scripts/basic/fixdep
        rm -f $kerneldir/build/scripts/asn1_compiler
        rm -f $(find $kerneldir/build/ -name "*\.dbg")
    )
    if [ "${S}" != "${B}" ];then
    (
        cd ${S}
        find . -depth -not -path "./.*" -print0 | cpio --null -pdu  $kerneldir/build/
    )
    fi
    find $kerneldir/build/ -path $kerneldir/build/lib -prune -o -path $kerneldir/build/tools -prune -o -path $kerneldir/build/scripts -prune -o -name "*.[cs]" -exec rm '{}' \;
    rm -rf $kerneldir/build/Documentation
    chown -R root:root ${D}
}

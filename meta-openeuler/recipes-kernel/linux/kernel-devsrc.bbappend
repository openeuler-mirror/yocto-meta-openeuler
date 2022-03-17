RDEPENDS_${PN} = ""
RDEPENDS_${PN}_remove_aarch64 = " gawk"

# not strip, host tools under scripts arch is different, cannot strip
# and cannot check arch in do_package_qa
INHIBIT_PACKAGE_STRIP = "1"
INSANE_SKIP_${PN} += "arch"

do_install_append() {
    # copy the entie source tree. copy source from build dir and then copy source dir
    # copy in parts from the build that we'll need later
    (
        cd ${B}
        find . -depth -not -name "*.cmd" -not -name "*.o" -not -path "./.*" -print0 | cpio --null -pdu  $kerneldir/build/
        cp .config $kerneldir/build/
        cp -a --parents arch/${ARCH}/include/generated/uapi/asm/ $kerneldir/build/
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

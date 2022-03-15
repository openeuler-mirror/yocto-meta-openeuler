RDEPENDS_${PN} = ""
RDEPENDS_${PN}_remove_aarch64 = " gawk"

do_install_append() {
    # copy in parts from the build that we'll need later
    (
        cd ${B}
        if [ "${ARCH}" = "arm64" ]; then
            cp -a --parents arch/arm64/include/generated/uapi/asm/ $kerneldir/build/
        fi
    )
    chown -R root:root ${D}
}

RDEPENDS_${PN} = ""
RDEPENDS_${PN}_remove_aarch64 = " gawk"

# not strip, host tools under scripts arch is different, cannot strip
# and cannot check arch in do_package_qa
# not check non -staticdev package contains static .a library
INHIBIT_PACKAGE_STRIP = "1"
INSANE_SKIP_${PN} += "arch staticdev"

do_install_append() {
    # prepare context for kernel module development
    pushd ${D}/usr/src/kernel/
    KBUILD_OUTPUT="" && oe_runmake modules_prepare
    popd
}

RDEPENDS:${PN} = ""
RDEPENDS:${PN}:remove:aarch64 = " gawk"

# not strip, host tools under scripts arch is different, cannot strip
# and cannot check arch in do_package_qa
INHIBIT_PACKAGE_STRIP = "1"
INSANE_SKIP:${PN} += "arch"

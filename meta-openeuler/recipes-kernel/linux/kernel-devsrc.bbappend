# kernel-devsrc.bb from oe-core commit id: a8fde81958fef39589e0df3f57c1dffd028d1631

RDEPENDS:${PN} = ""
RDEPENDS:${PN}:remove:aarch64 = " gawk"

# not strip, host tools under scripts arch is different, cannot strip
# and cannot check arch in do_package_qa
INHIBIT_PACKAGE_STRIP = "1"
INSANE_SKIP:${PN} += "arch"

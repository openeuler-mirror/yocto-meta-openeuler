# kernel-devsrc.bb from oe-core commit id: a8fde81958fef39589e0df3f57c1dffd028d1631

RDEPENDS:${PN} = ""
RDEPENDS:${PN}:remove:aarch64 = " gawk"

# not strip, host tools under scripts arch is different, cannot strip
# and cannot check arch in do_package_qa
INHIBIT_PACKAGE_STRIP = "1"
INSANE_SKIP:${PN} += "arch"

# kernel-devsrc ships host-side kernel build scripts that call
# /usr/bin/gawk and other host tools. The auto-generated file-level
# Requires(/usr/bin/gawk) has no provider in oe-repo/oe-sdk-repo
# (gawk is a host tool, not a target package), causing do_rootfs and
# do_populate_sdk (dnf) to fail with "nothing provides /usr/bin/gawk".
# Disable per-file dep generation so the RPM doesn't carry those Requires.
SKIP_FILEDEPS = "1"

ASSUME_PROVIDE_PKGS = "kernel-devel"

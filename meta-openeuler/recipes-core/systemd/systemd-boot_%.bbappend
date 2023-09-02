# main bb: openembedded-core/meta/recipes-core/systemd/systemd-boot_253.7.bb

# version in openEuler
PV = "253"
S = "${WORKDIR}/systemd-${PV}"

OPENEULER_REPO_NAME = "systemd"
require systemd-openeuler.inc

# glib needs meson, meson needs python3-native
# here use nativesdk's meson-native and python3-native
DEPENDS:remove = "python3-native"

# delete depends to util-linux-native
PACKAGECONFIG:remove:class-target = "libmount"

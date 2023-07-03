#main bbfile: yocto-poky/meta/recipes-core/systemd/systemd-boot_247.6.bb

#version in openEuler
PV = "249"
S = "${WORKDIR}/systemd-${PV}"

OPENEULER_REPO_NAME = "systemd"
require systemd-openeuler.inc

# sync from poky honister
# see: https://git.yoctoproject.org/poky/tree/meta/recipes-core/systemd/systemd-boot_249.7.bb?h=honister
EFI_LD = "${HOST_PREFIX}ld.bfd"
EXTRA_OEMESON:remove = "-Defi-ld=${@ d.getVar('LD').split()[0]} "
EXTRA_OEMESON += "-Defi-ld=${EFI_LD} "

SRC_URI[tarball.md5sum] = "8e8adf909c255914dfc10709bd372e69"
SRC_URI[tarball.sha256sum] = "174091ce5f2c02123f76d546622b14078097af105870086d18d55c1c2667d855"

# glib needs meson, meson needs python3-native
# here use nativesdk's meson-native and python3-native
DEPENDS:remove = "python3-native"

#delete depends to util-linux-native
PACKAGECONFIG:remove:class-target = "libmount"

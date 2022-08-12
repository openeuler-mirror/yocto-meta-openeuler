#main bbfile: yocto-poky/meta/recipes-core/systemd/systemd_247.6.bb

#version in openEuler
PV = "249"
S = "${WORKDIR}/${BP}"

require systemd-openeuler.inc

OPENEULER_REPO_NAME = "systemd"

# feture sync with systemd_249.7.bb from poky honister
# see https://git.yoctoproject.org/poky/tree/meta/recipes-core/systemd/systemd_249.7.bb?h=honister
PACKAGECONFIG += "wheel-group"
# we don't wan zstd PACKAGECONFIG += "zstd"
PACKAGECONFIG_remove += "xz"
PACKAGECONFIG[tpm2] = "-Dtpm2=true,-Dtpm2=false,tpm2-tss,tpm2-tss libtss2 libtss2-tcti-device"
PACKAGECONFIG[repart] = "-Drepart=true,-Drepart=false"
PACKAGECONFIG[homed] = "-Dhomed=true,-Dhomed=false"
PACKAGECONFIG[wheel-group] = "-Dwheel-group=true, -Dwheel-group=false"
PACKAGECONFIG[zstd] = "-Dzstd=true,-Dzstd=false,zstd"
FILES_${PN}-container += "${exec_prefix}/lib/tmpfiles.d/README "
FILES_${PN}-extra-utils += "${bindir}/systemd-sysext "
FILES_${PN} += "${rootlibexecdir}/modprobe.d/README ${datadir}/dbus-1/system.d/org.freedesktop.home1.conf "
FILES_udev += "${rootlibexecdir}/udev/dmi_memory_id \
        ${rootlibexecdir}/udev/rules.d/40-elevator.rules \
        ${rootlibexecdir}/udev/rules.d/70-memory.rules \
        ${rootlibexecdir}/udev/rules.d/73-idrac.rules \
        ${rootlibexecdir}/udev/rules.d/81-net-dhcp.rules \
        ${rootlibexecdir}/udev/rules.d/README \
        "
python __anonymous() {
    if not bb.utils.contains('DISTRO_FEATURES', 'sysvinit', True, False, d):
        d.setVar("INHIBIT_UPDATERCD_BBCLASS", "1")

    if bb.utils.contains('PACKAGECONFIG', 'repart', True, False, d) and not bb.utils.contains('PACKAGECONFIG', 'openssl', True, False, d):
        bb.error("PACKAGECONFIG[repart] requires PACKAGECONFIG[openssl]")

    if bb.utils.contains('PACKAGECONFIG', 'homed', True, False, d) and not bb.utils.contains('PACKAGECONFIG', 'userdb openssl cryptsetup', True, False, d):
        bb.error("PACKAGECONFIG[homed] requires PACKAGECONFIG[userdb], PACKAGECONFIG[openssl] and PACKAGECONFIG[cryptsetup]")
}
# rules.d come from openeuler patches: /lib/udev/rules.d/73-idrac.rules   /lib/udev/rules.d/40-elevator.rules
FILES_udev += " \
        ${rootlibexecdir}/udev/rules.d/40-elevator.rules \
        ${rootlibexecdir}/udev/rules.d/73-idrac.rules \
        "

SRC_URI[tarball.md5sum] = "8e8adf909c255914dfc10709bd372e69"
SRC_URI[tarball.sha256sum] = "174091ce5f2c02123f76d546622b14078097af105870086d18d55c1c2667d855"

# glib needs meson, meson needs python3-natve
# here use nativesdk's meson-native and python3-native
DEPENDS_remove += "python3-native"

#delete depends to util-linux-native
PACKAGECONFIG_remove_class-target += "libmount"

pkg_postinst_udev-hwdb () {
    # current we don't support qemuwrapper to pre build the config for rootfs
    # so if you wan't to update hwdb, do 'udevadm hwdb --update' in your own script on service or copy the configs into rootfs directly.
    :
}


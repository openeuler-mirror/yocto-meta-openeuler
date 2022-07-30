PV = "1.34.1"

DL_DIR = "${OPENEULER_SP_DIR}/${BPN}"

# files, patches can't be applied in openeuler or conflict with openeuler
SRC_URI_remove = " \
            file://busybox-udhcpc-no_deconfig.patch \
            file://0001-testsuite-check-uudecode-before-using-it.patch \
            file://0001-gen_build_files-Use-C-locale-when-calling-sed-on-glo.patch \
            file://0001-awk-fix-CVEs.patch \
            file://0002-man-fix-segfault-in-man-1.patch \
            "

# files, patches that come from openeuler
SRC_URI += ""

SRC_URI[tarball.sha256sum] = "415fbd89e5344c96acf449d94a6f956dbed62e18e835fc83e064db33a34bd549"

# current we not enable sysvint in DISTRO_FEATURES, just use busybox's init, but we want populate_packages_updatercd to work.
# In other word, we want update-rc.d always work when INITSCRIPT_NAME and INITSCRIPT_PARAMS generate with all none systemd scene.
# update-rc.d config from yocto-poky/meta/recipes-core/busybox/busybox.inc:
# INITSCRIPT_NAME_${PN}-httpd = "busybox-httpd"
# INITSCRIPT_NAME_${PN}-hwclock = "hwclock.sh"
# INITSCRIPT_NAME_${PN}-mdev = "mdev"
# INITSCRIPT_PARAMS_${PN}-mdev = "start 04 S ."
# INITSCRIPT_NAME_${PN}-syslog = "syslog"
# INITSCRIPT_NAME_${PN}-udhcpd = "busybox-udhcpd"
PACKAGESPLITFUNCS_prepend = "${@bb.utils.contains('DISTRO_FEATURES', 'systemd', '', 'populate_packages_updatercd ', d)}"


# main bbfile: yocto-meta-openembedded/meta-oe/recipes-multimedia/v4l2apps/v4l-utils_1.20.0.bb

OPENEULER_REPO_NAME = "v4l-utils"
OPENEULER_SRC_URI_REMOVE = "https http git"

PV = "1.14.2"

# file can't apply form oe
SRC_URI:remove += " \
        file://0001-Revert-media-ctl-Don-t-install-libmediactl-and-libv4.patch \
        file://mediactl-pkgconfig.patch \
        file://export-mediactl-headers.patch \
        file://0002-contrib-test-Link-mc_nextgen_test-with-libargp-if-ne.patch \
        file://0007-Do-not-use-getsubopt.patch \
        file://0008-configure.ac-autodetect-availability-of-systemd.patch \
        file://0009-keytable-restrict-installation-of-50-rc_keymap.conf.patch \
        "

# source change to openEuler
SRC_URI += " \
        file://v4l-utils-${PV}.tar.bz2 \
        file://v4l-utils-sysmacros.patch \
        file://0001-fix-compilation-failed.patch \
        "

# we don't want feature of udev and keymaps for out embedded OS, if use, delete those code.
DEPENDS:remove:class-target += "udev"
EXTRA_OECONF = "--disable-qv4l2 --enable-shared"
PACKAGES:remove += " ir-keytable rc-keymaps "
FILES_ir-keytable = ""
RDEPENDS_ir-keytable = ""
FILES_rc-keymaps = ""
# udev and keymaps files still generated, so we put in a package and may not pack in rootfs
PACKAGES:append += " udev-keymaps "
FILES_udev-keymaps = "${sysconfdir}/rc* ${base_libdir}/udev* ${libdir}/udev* /lib/udev"

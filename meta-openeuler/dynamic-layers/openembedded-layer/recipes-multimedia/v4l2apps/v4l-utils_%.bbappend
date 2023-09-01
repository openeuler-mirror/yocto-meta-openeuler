# main bbfile: yocto-meta-openembedded/meta-oe/recipes-multimedia/v4l2apps/v4l-utils_1.20.0.bb

OPENEULER_REPO_NAME = "v4l-utils"
OPENEULER_SRC_URI_REMOVE = "https http git"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

PV = "1.24.1"

# file can't apply form oe
SRC_URI:remove = " \
        "

# source change to openEuler
SRC_URI += " \
        file://v4l-utils-${PV}.tar.bz2 \
        "

S = "${WORKDIR}/v4l-utils-${PV}"

# we don't want feature of udev and keymaps for out embedded OS, if use, delete those code.
DEPENDS:remove:class-target = "udev"
EXTRA_OECONF = "--disable-qv4l2 --enable-shared"
PACKAGES:remove = " ir-keytable rc-keymaps "
FILES:ir-keytable = ""
RDEPENDS:ir-keytable = ""
FILES:rc-keymaps = ""
# udev and keymaps files still generated, so we put in a package and may not pack in rootfs
PACKAGES:append = " udev-keymaps "
FILES:udev-keymaps = "${sysconfdir}/rc* ${base_libdir}/udev* ${libdir}/udev* /lib/udev"

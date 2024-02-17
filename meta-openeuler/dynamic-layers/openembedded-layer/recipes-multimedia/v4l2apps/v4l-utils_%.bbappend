# main bbfile: yocto-meta-openembedded/meta-oe/recipes-multimedia/v4l2apps/v4l-utils_1.20.0.bb
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

PV = "1.24.1"

# source change to openEuler
SRC_URI += " \
        file://${BP}.tar.bz2 \
        "

S = "${WORKDIR}/${BP}"

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

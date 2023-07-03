FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

SRC_URI:prepend = " \
        file://00-originbot-navigation-fix-humble.patch \
        file://01-originbot-navigation-fix-amcl-load-error.patch \
        "

FILES:${PN} += "/usr/share /usr/lib"

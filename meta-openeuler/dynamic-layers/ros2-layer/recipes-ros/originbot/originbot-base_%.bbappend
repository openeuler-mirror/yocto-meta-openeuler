FILESEXTRAPATHS:prepend := "${THISDIR}/files/:"

SRC_URI:prepend = " \
        file://00-originbot-base-fix-error.patch \
        "

FILES:${PN} += "/usr/share /usr/lib"

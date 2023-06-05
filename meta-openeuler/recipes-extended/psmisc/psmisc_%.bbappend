# package and patches from openeuler
PV = "23.5"

SRC_URI = " \
    file://psmisc-${PV}.tar.xz \
"

# patches from poky
SRC_URI += " \
           file://0001-Use-UINTPTR_MAX-instead-of-__WORDSIZE.patch \
"

S = "${WORKDIR}/${BPN}-${PV}"

do_configure_prepend() {
    # cannot run po/update-potfiles in new version
    if [ ! -f ${S}/po/update-potfiles ]; then
        touch ${S}/po/update-potfiles
        chmod +x ${S}/po/update-potfiles
    fi
}

SRC_URI[md5sum] = "fd08c7f1290926d063cab4a8c99af2f9"
SRC_URI[sha256sum] = "3c276873deec008b1c442810ad638a5bc871e80bc562a59c49ffc21d4ec0d074"

# package and patches from openeuler
SRC_URI = " \
    file://psmisc-${PV}.tar.xz \
    file://backport-patch-fix-checking-truncated-process-names.patch \
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

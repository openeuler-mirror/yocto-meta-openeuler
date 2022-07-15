# package and patches from openeuler
SRC_URI = " \
    file://psmisc-${PV}.tar.xz \
"

# patches from poky
SRC_URI += " \
           file://0001-Use-UINTPTR_MAX-instead-of-__WORDSIZE.patch \
"

S = "${WORKDIR}/${BPN}-${PV}"

do_configure_openeuler() {
    # cannot run po/update-potfiles in new version
    autotools_do_configure
}

deltask do_configure
addtask configure_openeuler before do_compile after do_patch do_unpack

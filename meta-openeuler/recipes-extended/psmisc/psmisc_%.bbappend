# package and patches from openeuler
SRC_URI = " \
    file://psmisc-${PV}.tar.xz \
"

# patches from poky
SRC_URI += " \
           file://0001-Use-UINTPTR_MAX-instead-of-__WORDSIZE.patch \
"

S = "${WORKDIR}/${BPN}-${PV}"

do_config_openeuler() {
    # cannot run po/update-potfiles in new version
    mkdir -p ${B}
    cd ${B}
    autotools_do_configure
}

do_configure[noexec] = "1"
addtask config_openeuler before do_compile after do_patch do_unpack

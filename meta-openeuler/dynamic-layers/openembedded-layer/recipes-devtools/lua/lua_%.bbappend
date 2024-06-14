LIC_FILES_CHKSUM = "file://doc/readme.html;beginline=307;endline=330;md5=79c3f6b19ad05efe24c1681f025026bb"
PV = "5.4.3"
PV_testsuites = "5.4.3"
MINOR_VERSION = "5.4"

FILESEXTRAPATHS_prepend := "${THISDIR}/files/:"

SRC_URI = " \
    file://lua-${PV}.tar.gz;name=tarballsrc \
    file://lua-5.4.0-beta-autotoolize.patch \
    file://lua-5.3.0-idsize.patch \
    file://lua-5.2.2-configure-linux.patch \
    file://lua-5.3.0-configure-compat-module.patch \
    file://backport-CVE-2021-44647.patch \
    file://backport-CVE-2022-33099.patch \
    file://backport-luaV_concat-can-use-invalidated-pointer-to-stack.patch \
    file://backport-Simpler-implementation-for-tail-calls.patch \
    file://backport-C-functions-can-be-tail-called-too.patch \
    file://backport-Simplification-in-the-parameters-of-luaD_precall.patch \
    file://backport-Undo-simplification-of-tail-calls-commit-901d760.patch \
    file://backport-luaD_tryfuncTM-checks-stack-space-by-itself.patch \
    file://backport-Using-inline-in-some-functions.patch \
    file://backport-Removed-goto-s-in-luaD_precall.patch \
    file://backport-More-uniform-implementation-for-tail-calls.patch \
    file://backport-CVE-2021-45985.patch \
"
# the follow patchs can not apply successful, and it just used to ptest，
# so don't patch them as a provisional workaround
# file://backport-CVE-2021-43519.patch
# file://backport-CVE-2022-28805.patch
# file://backport-CVE-2021-44964.patch
# file://backport-Bug-stack-overflow-with-nesting-of-coroutine.close.patch
# file://backport-Bug-Loading-a-corrupted-binary-file-can-segfault.patch
# file://backport-Bug-Recursion-in-getobjname-can-stack-overflow.patch
# file://backport-Emergency-new-version-5.4.6.patch

SRC_URI += "\
    file://lua-${PV_testsuites}-tests.tar.gz;name=tarballtest \
    file://run-ptest \
    file://lua.pc.in \       
"

SRC_URI[tarballsrc.md5sum] = "ef63ed2ecfb713646a7fcc583cf5f352"
SRC_URI[tarballsrc.sha256sum] = "f8612276169e3bfcbcfb8f226195bfc6e466fe13042f1076cbde92b7ec96bbfb"
SRC_URI[tarballtest.md5sum] = "4afc92b7e45fc0687c686a470bc8072a"
SRC_URI[tarballtest.sha256sum] = "5d29c3022897a8290f280ebe1c6853248dfa35a668e1fc02ba9c8cde4e7bf110"

EXTRA_OEMAKE = "'CC=${CC} -fPIC' 'MYCFLAGS=${CFLAGS} -fPIC' MYLDFLAGS='${LDFLAGS}' 'AR=ar rcD' 'RANLIB=ranlib -D'"

do_prepare_before_patch() {
    cd ${S}
    # openeuler has change its name, and patch it
    cp -f src/luaconf.h src/luaconf.h.template.in
    cd -
}

addtask do_prepare_before_patch before do_patch after do_unpack

do_compile () {
    oe_runmake ${@bb.utils.contains('PACKAGECONFIG', 'readline', 'linux-readline', 'linux', d)}
}

# use MINOR_VERSION instead of 5.3
do_install () {
    oe_runmake \
        'INSTALL_TOP=${D}${prefix}' \
        'INSTALL_BIN=${D}${bindir}' \
        'INSTALL_INC=${D}${includedir}/' \
        'INSTALL_MAN=${D}${mandir}/man1' \
        'INSTALL_SHARE=${D}${datadir}/lua' \
        'INSTALL_LIB=${D}${libdir}' \
        'INSTALL_CMOD=${D}${libdir}/lua/${MINOR_VERSION}' \
        install
    install -d ${D}${libdir}/pkgconfig

    sed -e s/@VERSION@/${PV}/ ${WORKDIR}/lua.pc.in > ${WORKDIR}/lua.pc
    install -m 0644 ${WORKDIR}/lua.pc ${D}${libdir}/pkgconfig/
    rmdir ${D}${datadir}/lua/${MINOR_VERSION}
    rmdir ${D}${datadir}/lua
}

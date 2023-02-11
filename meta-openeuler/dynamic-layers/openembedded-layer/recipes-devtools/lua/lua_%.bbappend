LIC_FILES_CHKSUM = "file://doc/readme.html;beginline=307;endline=330;md5=79c3f6b19ad05efe24c1681f025026bb"
PV = "5.4.3"
PV_testsuites = "5.4.3"
MINOR_VERSION = "5.4"

# remove patches out of date
SRC_URI_remove = "file://0001-Allow-building-lua-without-readline-on-Linux.patch  \
           file://CVE-2020-15888.patch \
           file://CVE-2020-15945.patch \
           file://0001-Fixed-bug-barriers-cannot-be-active-during-sweep.patch \
"

# openeuler has patches for lua-${PV}-tests
SRC_URI += " \
           http://www.lua.org/tests/lua-${PV}-tests.tar.gz;name=tarballtest;subdir=${BP}/ \
           file://run-ptest \
           file://lua-5.4.0-beta-autotoolize.patch \
           file://lua-5.3.0-idsize.patch \
           file://lua-5.2.2-configure-linux.patch \
           file://lua-5.3.0-configure-compat-module.patch \
           file://backport-CVE-2021-43519.patch \
           file://backport-CVE-2021-44647.patch \
           file://backport-CVE-2022-28805.patch \
           file://backport-CVE-2022-33099.patch \
           file://backport-CVE-2021-44964.patch \
           file://backport-luaV_concat-can-use-invalidated-pointer-to-stack.patch \
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

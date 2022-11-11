DESCRIPTION = "Lua is a powerful light-weight programming language designed \
for extending applications."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://doc/readme.html;beginline=318;endline=352;md5=af9cf21da2719d2ffe92251babfa3b83"
HOMEPAGE = "http://www.lua.org/"

DEPENDS = "readline"
MINOR_VERSION = "5.4"
SRC_URI = "http://www.lua.org/ftp/lua-${PV}.tar.gz;name=tarballsrc \
           file://lua.pc.in \
           "

# openeuler has patches for lua-${PV}-tests
SRC_URI += " \
        http://www.lua.org/tests/lua-${PV}-tests.tar.gz;name=tarballtest;subdir=${BP}/ \
        file://run-ptest \
        file://luaconf.h \
        file://mit.txt \
        file://macros.lua \
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

inherit pkgconfig binconfig ptest

UCLIBC_PATCHES += "file://uclibc-pthread.patch"
SRC_URI_append_libc-uclibc = "${UCLIBC_PATCHES}"

TARGET_CC_ARCH += " -fPIC ${LDFLAGS}"
EXTRA_OEMAKE = "'CC=${CC} -fPIC' 'MYCFLAGS=${CFLAGS} -DLUA_USE_LINUX -fPIC' MYLDFLAGS='${LDFLAGS}'"

do_configure_prepend() {
    sed -i -e s:/usr/local:${prefix}:g src/luaconf.h
}

do_compile () {
    oe_runmake linux
}

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

do_install_ptest () {
        cp -R --no-dereference --preserve=mode,links -v ${WORKDIR}/lua-${PV}-tests ${D}${PTEST_PATH}/test
}

BBCLASSEXTEND = "native nativesdk"

do_prepare_before_patch() {
    pushd ${S}
    # openeuler has change its name, and patch it
    cp -f src/luaconf.h src/luaconf.h.template.in
    popd
}

addtask do_prepare_before_patch before do_patch after do_unpack

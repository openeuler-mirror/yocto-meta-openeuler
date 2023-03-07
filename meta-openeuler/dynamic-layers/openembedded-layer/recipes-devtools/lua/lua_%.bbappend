LIC_FILES_CHKSUM = "file://doc/readme.html;beginline=307;endline=330;md5=79c3f6b19ad05efe24c1681f025026bb"
PV = "5.4.4"
PV_testsuites = "5.4.3"
MINOR_VERSION = "5.4"

OPENEULER_BRANCH = "openEuler-23.03"

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
           file://backport-CVE-2022-28805.patch \
           file://backport-CVE-2022-33099.patch \
           file://backport-luaV_concat-can-use-invalidated-pointer-to-stack.patch \
"

SRC_URI[tarballsrc.md5sum] = "bd8ce7069ff99a400efd14cf339a727b"
SRC_URI[tarballsrc.sha256sum] = "164c7849653b80ae67bec4b7473b884bf5cc8d2dca05653475ec2ed27b9ebf61"
SRC_URI[tarballtest.md5sum] = "0e28a9b48b3596d6b12989d04ae403c4"
SRC_URI[tarballtest.sha256sum] = "04d28355cd67a2299dfe5708b55a0ff221ccb1a3907a3113cc103ccc05ac6aad"

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

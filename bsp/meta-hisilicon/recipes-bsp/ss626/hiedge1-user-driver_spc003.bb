SUMMARY = "hiedge1 user driver bin package"
DESCRIPTION = "user lib and headers repack from SS626V100_SDK"
HOMEPAGE = "https://gitee.com/HiEuler/hardware_driver"
LICENSE = "CLOSED"

inherit pkgconfig

# This driver library is depended by many ROS packages,
# using the "lib" directory instead of the "lib64" directory
# for ros feature
python roslike_libdir_set() {
    if bb.utils.contains('DISTRO_FEATURES', 'ros', True, False, d):
        old_pkg_config = d.getVar("PKG_CONFIG_SYSROOT_DIR") + d.getVar('libdir') + "/pkgconfig"
        pn = e.data.getVar("PN")
        if pn.endswith("-native"):
            return
        d.setVar('libdir', d.getVar('libdir').replace('64', ''))
        d.setVar('baselib', d.getVar('baselib').replace('64', ''))
        d.appendVar("PKG_CONFIG_PATH", old_pkg_config)
}

addhandler roslike_libdir_set
roslike_libdir_set[eventmask] = "bb.event.RecipePreFinalise"

OPENEULER_LOCAL_NAME = "HiEdge-driver"

SRC_URI = " \
        file://HiEdge-driver/drivers/lib.tar.gz \
        file://HiEdge-driver/drivers/include.tar.gz \
        file://hiedge1-user-driver.pc.in \
"

S = "${WORKDIR}"

do_install:append() {
    install -d ${D}${libdir}
    install -d ${D}/usr/include
    cp -rf -P ${WORKDIR}/lib/* ${D}${libdir}
    cp -rf -P ${WORKDIR}/include/* ${D}/usr/include/
    cd ${D}${libdir}
    cd -
    sed \
    -e s#@VERSION@#${PV}# \
    -e s#@prefix@#${prefix}# \
    -e s#@exec_prefix@#${exec_prefix}# \
    -e s#@libdir@#${libdir}# \
    -e s#@includedir@#${includedir}# \
    ${WORKDIR}/hiedge1-user-driver.pc.in > ${WORKDIR}/hiedge1-user-driver.pc

    install -d ${D}${libdir}/pkgconfig
    install -m 0644 ${WORKDIR}/hiedge1-user-driver.pc ${D}${libdir}/pkgconfig/

}

FILES:${PN} += " \
    ${libdir}/*so* \
    ${libdir}/svp_npu/*so* \
"

FILES:${PN}-dev = " \
    ${includedir} \
    ${libdir}/pkgconfig \
"

FILES:${PN}-staticdev += " \
    ${libdir}/svp_npu/*a \
"

# hiedge1-user-driver package provides library with the same name but located in different paths,
# which will lead to the following dependency issues when detecting the shlib:
# do_package: hiedge1-user-driver: Multiple shlib providers for libascendcl.so: hiedge1-user-driver, hiedge1-user-driver ...
# set these as private libraries, don't try to search provider for it
# PRIVATE_LIBS = "libgraph.so libascendcl.so "

INSANE_SKIP:${PN} += "already-stripped dev-so"

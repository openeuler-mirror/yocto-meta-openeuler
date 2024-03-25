SUMMARY = "openEuler embedded softbus capability support"
DESCRIPTION = "OpenEuler supports param service for distributed softbus capability"
PR = "r1"
LICENSE = "CLOSED"

require distributed-build.inc
require c-utils-gn.inc

pkg-beget = "init"

SRC_URI += " \
            file://distributed-beget/${PN}.tar.gz \
            file://distributed-beget/0001-fixbug_fd_leak_for_init.patch;patchdir=${WORKDIR}/${pkg-beget} \
            file://distributed-beget/0002-feat-for-embedded-fix-compile-errors.patch;patchdir=${WORKDIR}/${pkg-beget} \
            file://distributed-beget/0003-feat-for-embedded-fix-sysroot-hilog-path.patch;patchdir=${WORKDIR}/${pkg-beget} \
            "

DEPENDS += "hilog"

RDEPENDS:${PN} = "libboundscheck"

FILES:${PN}-dev = "${includedir}"
FILES:${PN} = "${libdir} ${bindir}"

do_patch:append() {
    bb.build.exec_func('do_prepare_hilog_gn_directory', d)
    bb.build.exec_func('do_prepare_beget_directory', d)
}

do_prepare_beget_directory() {
    mkdir -p ${S}/base/startup/init
    cp -rfp ${WORKDIR}/${pkg-beget}/* ${S}/base/startup/init
}

do_compile() {
    cd ${S}
    ./build.sh --product-name openeuler --target-cpu arm64 -v --gn-args is_clang=false --gn-args use_gold=false --gn-args target_sysroot=\"${RECIPE_SYSROOT}\"
}

do_install() {
    install -d -m 0755 ${D}/${includedir}/init/syspara/
    install -d -m 0755 ${D}/${includedir}/init/param/
    install -d -m 0755 ${D}/${libdir}/
    install -d -m 0755 ${D}/${bindir}/
    # install -d -m 0755 ${D}/system/lib64/

    # bin
    install -m 0755 ${S}/out/openeuler/packages/phone/system/bin/param_service ${D}/${bindir}/
    # shared library
    install -m 0755 ${S}/out/openeuler/linux_arm64/startup/init/libbeget_proxy.z.so ${D}/${libdir}/
    install -m 0755 ${S}/out/openeuler/linux_arm64/startup/init/libbegetutil.z.so ${D}/${libdir}/
    # install -m 0755 ${S}/out/openeuler/linux_arm64/startup/init/libbeget_proxy.z.so ${D}/system/lib64/
    # install -m 0755 ${S}/out/openeuler/linux_arm64/startup/init/libbegetutil.z.so ${D}/system/lib64/
    # header files
    install -m 0755 ${S}/base/startup/init/interfaces/innerkits/include/{beget_ext.h,service_watcher.h,service_control.h} ${D}/${includedir}/init/
    install -m 0755 ${S}/base/startup/init/interfaces/innerkits/include/syspara/* ${D}/${includedir}/init/syspara/
    install -m 0755 ${S}/base/startup/init/interfaces/innerkits/include/syspara/* ${D}/${includedir}/init/
    install -m 0755 ${S}/base/startup/init/services/include/init_utils.h ${D}/${includedir}/init/
    install -m 0755 ${S}/base/startup/init/services/include/param/* ${D}/${includedir}/init/param/
    install -m 0755 ${S}/base/startup/init/services/include/param/* ${D}/${includedir}/init/
}
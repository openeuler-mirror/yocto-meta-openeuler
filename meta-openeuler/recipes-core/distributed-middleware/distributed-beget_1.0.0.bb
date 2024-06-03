SUMMARY = "openEuler embedded softbus capability support"
DESCRIPTION = "OpenEuler supports param service for distributed softbus capability"
PR = "r1"
LICENSE = "CLOSED"

require distributed-build.inc

pkg-beget = "init"

SRC_URI += " \
            file://${BPN}.tar.gz \
            file://distributed-beget/0001-fixbug_fd_leak_for_init.patch;patchdir=${WORKDIR}/${pkg-beget} \
            file://distributed-beget/0002-feat-for-embedded-fix-compile-errors.patch;patchdir=${WORKDIR}/${pkg-beget} \
            file://distributed-beget/0003-feat-for-embedded-fix-sysroot-hilog-path.patch;patchdir=${WORKDIR}/${pkg-beget} \
            file://distributed-beget/0004-refactor-using-the-reactor-framework.patch;patchdir=${WORKDIR}/${pkg-beget} \
            file://distributed-beget/0005-feat-for-embedded-fix-compile-errors-after-refactor.patch;patchdir=${WORKDIR}/${pkg-beget} \
            file://distributed-beget/startup.bundle.json \
            file://distributed-beget/startup.BUILD.gn \
            "

DEPENDS += "hilog c-utils"

RDEPENDS:${PN} = "libboundscheck"

FILES:${PN}-dev = "${includedir} /compiler_gn"
FILES:${PN} = "${libdir} ${bindir} /system"

INSANE_SKIP:${PN} += "dev-so"

do_configure:prepend() {
    cp -rf ${RECIPE_SYSROOT}/compiler_gn/* ${S}/
    mkdir -p ${S}/base/startup/init
    cp -rf ${WORKDIR}/${pkg-beget}/* ${S}/base/startup/init
}

do_compile() {
    cd ${S}
    ./build.sh --product-name openeuler --target-cpu arm64 -v --gn-args is_clang=${is_clang} --gn-args use_gold=false --gn-args target_sysroot=\"${RECIPE_SYSROOT}\"
}

do_install() {
    install -d -m 0755 ${D}/${includedir}/init/syspara/
    install -d -m 0755 ${D}/${includedir}/init/param/
    install -d -m 0755 ${D}/${libdir}/
    install -d -m 0755 ${D}/${bindir}/
    install -d -m 0755 ${D}/system/lib64/

    # bin
    install -m 0755 ${S}/out/openeuler/packages/phone/system/bin/param_service ${D}/${bindir}/
    # shared library
    install -m 0755 ${S}/out/openeuler/linux_*arm64/startup/init/libbeget_proxy.z.so ${D}/${libdir}/
    install -m 0755 ${S}/out/openeuler/linux_*arm64/startup/init/libbegetutil.z.so ${D}/${libdir}/
    ln -s ../../${libdir}/libbeget_proxy.z.so ${D}/system/lib64/libbeget_proxy.z.so
    ln -s ../../${libdir}/libbegetutil.z.so ${D}/system/lib64/libbegetutil.z.so
    # header files
    install -m 554 ${S}/base/startup/init/interfaces/innerkits/include/{beget_ext.h,service_watcher.h,service_control.h} ${D}/${includedir}/init/
    install -m 554 ${S}/base/startup/init/interfaces/innerkits/include/syspara/* ${D}/${includedir}/init/syspara/
    install -m 554 ${S}/base/startup/init/interfaces/innerkits/include/syspara/* ${D}/${includedir}/init/
    install -m 554 ${S}/base/startup/init/services/include/init_utils.h ${D}/${includedir}/init/
    install -m 554 ${S}/base/startup/init/services/include/param/* ${D}/${includedir}/init/param/
    install -m 554 ${S}/base/startup/init/services/include/param/* ${D}/${includedir}/init/

    # copy bundle
    mkdir -p ${D}/compiler_gn/base/startup/init/interfaces/innerkits/
    cp -rf ${WORKDIR}/distributed-beget/startup.bundle.json ${D}/compiler_gn/base/startup/init/bundle.json
    cp -rf ${WORKDIR}/distributed-beget/startup.BUILD.gn ${D}/compiler_gn/base/startup/init/interfaces/innerkits/BUILD.gn
}

SYSROOT_DIRS += "/compiler_gn"

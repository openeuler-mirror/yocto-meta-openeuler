SUMMARY = "System ability manager"
DESCRIPTION = "OpenEuler supports samgr for distributed softbus capability"
PR = "r1"
LICENSE = "CLOSED"

require distributed-build.inc

pkg-samgr = "systemabilitymgr_samgr-${openHarmony_release_version}"

OPENEULER_REPO_NAME = "systemabilitymgr_samgr"

SRC_URI += " \
            file://${pkg-samgr}.tar.gz \
            file://systemabilitymgr_samgr/0001-adapt-compilation-for-samgr.patch;patchdir=${WORKDIR}/${pkg-samgr} \
            file://systemabilitymgr_samgr/bundle.json \
            file://systemabilitymgr_samgr/samgr_common.gn \
            file://systemabilitymgr_samgr/samgr_proxy.gn \
            "

DEPENDS += "hilog c-utils distributed-beget eventhandler ipc libxml2"

RDEPENDS:${PN} = "libboundscheck"

FILES:${PN}-dev = "${includedir} /compiler_gn"
FILES:${PN} = "${libdir} ${bindir} /system"

INSANE_SKIP:${PN} += "dev-so"

do_configure:prepend() {
    cp -rf ${RECIPE_SYSROOT}/compiler_gn/* ${S}/
    mkdir -p ${S}/foundation/systemabilitymgr/samgr/
    cp -rf ${WORKDIR}/${pkg-samgr}/* ${S}/foundation/systemabilitymgr/samgr/
}

do_compile() {
    cd ${S}
    ./build.sh --product-name openeuler --target-cpu arm64 -v --gn-args is_clang=false --gn-args use_gold=false --gn-args target_sysroot=\"${RECIPE_SYSROOT}\"
}

do_install() {
    install -d -m 0755 ${D}/${includedir}/samgr/
    install -d -m 0755 ${D}/${libdir}/
    install -d -m 0755 ${D}/${bindir}/
    install -d -m 0755 ${D}/system/bin/
    install -d -m 0755 ${D}/system/lib64/

    # copy executable file.
    install -m 755 ${S}/out/openeuler/packages/phone/system/bin/samgr ${D}/${bindir}
    ln -s ../../${bindir}/samgr ${D}/system/bin/samgr
    
    # prepare so
    install -m 0755 ${S}/out/openeuler/linux_arm64/systemabilitymgr/samgr/libsamgr*.so ${D}/${libdir}/
    ln -s ../../${libdir}/libsamgr_common.z.so ${D}/system/lib64/libsamgr_common.z.so
    ln -s ../../${libdir}/libsamgr_proxy.z.so ${D}/system/lib64/libsamgr_proxy.z.so

    # prepare head files
    install -m 554 ${S}/foundation/systemabilitymgr/samgr/services/lsamgr/include/*.h ${D}/${includedir}/samgr/
    install -m 554 ${S}/foundation/systemabilitymgr/samgr/interfaces/innerkits/common/include/*.h ${D}/${includedir}/samgr/
    install -m 554 ${S}/foundation/systemabilitymgr/samgr/interfaces/innerkits/samgr_proxy/include/*.h ${D}/${includedir}/samgr/

    # copy bundle
    mkdir -p ${D}/compiler_gn/foundation/systemabilitymgr/samgr/interfaces/innerkits/common/
    mkdir -p ${D}/compiler_gn/foundation/systemabilitymgr/samgr/interfaces/innerkits/samgr_proxy/
    cp -rf ${WORKDIR}/systemabilitymgr_samgr/bundle.json  ${D}/compiler_gn/foundation/systemabilitymgr/samgr/bundle.json
    cp -rf ${WORKDIR}/systemabilitymgr_samgr/samgr_common.gn ${D}/compiler_gn/foundation/systemabilitymgr/samgr/interfaces/innerkits/common/BUILD.gn
    cp -rf ${WORKDIR}/systemabilitymgr_samgr/samgr_proxy.gn ${D}/compiler_gn/foundation/systemabilitymgr/samgr/interfaces/innerkits/samgr_proxy/BUILD.gn
}

SYSROOT_DIRS += "/compiler_gn"